# Moving the app to Firebase

Status: design, not built. Scope: replace `cats.json` + local photos with Firestore + Cloud
Storage behind anonymous Firebase Auth, offline-first, owner-only, and import David's
existing cats once.

**The shape in one paragraph.** Each user has two flat collections, `users/{uid}/cats` and
`users/{uid}/encounters` (each encounter points at its cat by `catId`). The app listens to
both and rebuilds today's `List<Cat>` domain model, so screens barely change. Photos live in
`users/{uid}/photos/{photoId}.jpg` in Storage, readable only by the owner, never through
download URLs. The phone keeps every photo in the existing `<documents>/cats/` folder, which
becomes the local photo store, and a small outbox there uploads new photos when online.

## 1. Firestore data

```
users/{uid}                          (no document yet; reserved for a future profile)
users/{uid}/cats/{catId}
  name        string   0..100 chars, the user's own name for the cat ('' = none yet)
  updatedAt   timestamp  server time (FieldValue.serverTimestamp(), rules: == request.time)
users/{uid}/encounters/{encounterId}
  catId       string   id of a cat in users/{uid}/cats
  photoId     string   optional; the photo is users/{uid}/photos/{photoId}.jpg
  takenAt     timestamp  client time the photo was taken (the user's truth, works offline)
  activity    string   optional; eating | sleeping | resting | waiting_at_door | playing | walking_by
  conditions  list     optional; healthy | thin | limping | unwell_or_injured | with_kittens | ear_tipped
  care        list     optional; fed | gave_water | took_to_vet | gave_medicine
  note        string   optional; the story, at most 1000 chars
                       (old documents may still have `type`: seen | fed | unwell | kittens | ear_tipped;
                       it is mapped on read and dropped on the next save; rules no longer accept it)
  updatedAt   timestamp  server time, as above
```

**Why a flat `encounters` collection, not an array in the cat or a per-cat subcollection.**
- An array can't be validated item by item in rules (rules have no loops), and editing one
  encounter means rewriting the whole array.
- A per-cat subcollection needs one listener per cat, or a collection-group query with an
  owner field duplicated into each document.
- Flat, one listener per collection, rules check every field. Moving an encounter to another
  of *my* cats ("that was actually Ciccio") is a one-field update of `catId`, the base for a
  later merge/split of one's own records.
- Writes are plain `set`/batched writes, which work offline (transactions do not).

**IDs.** Client-made, so they exist offline. Keep today's scheme: a new photo is
`<millis>.jpg`, the encounter id and `photoId` are that `<millis>`, and a new cat takes its
first encounter's id. Import reuses the ids in `cats.json` exactly, which is what makes it
idempotent. Rules accept `^[A-Za-z0-9_-]{1,64}$`, so auto-ids can replace millis later.

**Timestamps.** `takenAt` is client time (when the cat was met, also for imported history).
`updatedAt` is server time, enforced by rules; offline it resolves when the write syncs. Read
snapshots with `ServerTimestampBehavior.estimate`; nothing sorts on `updatedAt`.

**No user-facing text.** `type` is the enum's stored `value`; labels stay in the l10n files.
`name` is the user's own words, not app text.

**Room for later (do not add now; each needs a rules change):**
- Location, per encounter: `exactPlace` (GeoPoint, owner-only, never copied anywhere) and
  `area` (a coarse neighbourhood id or geohash prefix, the only thing a card may show).
- Cross-user links ("your Ninja is my Güero"): a separate top-level `links/{linkId}`
  collection, e.g. `{members: [uidA, uidB], records: {uidA: catId, uidB: catId}, status}`,
  created and confirmed by people. Users' own records are never edited by a link, and each
  keeps their own name. Anything shown to another user comes from a separate, safe
  projection, never by opening `users/{uid}` to others.

## 2. Photos in Cloud Storage

- Path: `users/{uid}/photos/{photoId}.jpg`, `contentType: image/jpeg`, under 10 MiB.
- Smaller photos from now on: `pickImage(source: camera, maxWidth: 2048, imageQuality: 85)`,
  about 0.3 to 0.8 MB each. No thumbnails: tiles already decode with `cacheWidth`, and
  photos are local after the first view. Revisit (Resize Images extension) only if needed.
- **Private.** Never call `getDownloadURL()` and never store a URL. Read with
  `ref.writeToFile(...)`, which is checked by the rules. (Storage creates a download token
  for each uploaded object; we never read or share it.)

**Local photo store.** The existing `<documents>/cats/` folder keeps `{photoId}.jpg` for
every photo this phone has: taken here, imported, or downloaded. It is the cache and the
upload source, and is never evicted (a user's own photos; that is no more than today).

**Offline upload: an outbox of marker files.** `firebase_storage` uploads don't survive an
app restart, so the app owns retries:
1. `takePhoto()` saves `<documents>/cats/<millis>.jpg` (as today). Backing out deletes it.
2. Recording the sighting writes the Firestore batch (applied locally at once) and creates
   an empty marker `<documents>/cats/outbox/{photoId}`.
3. `PhotoUploader` drains the outbox: for each marker, `putFile` with
   `SettableMetadata(contentType: 'image/jpeg')`, then delete the marker. On failure it
   stops and tries again later. Triggers: app start (after sign-in), each new marker, app
   resume, and every 5 minutes while in the foreground. Set
   `FirebaseStorage.setMaxUploadRetryTime` to about 1 minute so the outbox owns the retries.
   A marker whose file is gone is dropped and logged. Overwriting is allowed, so a re-upload
   after a crash is harmless.

**Showing a photo.** `photoFileProvider(photoId)` (FutureProvider.family) returns the local
file if present; otherwise downloads it to `{photoId}.jpg.part`, renames it, and returns it.
Null (offline, or not yet uploaded from another device) shows the existing placeholder.
A not-yet-uploaded photo looks exactly like any other because it is the local file; there is
no visible "uploading" state for now.

## 3. Security rules

Files: `app/firestore.rules`, `app/storage.rules`, referenced from `app/firebase.json`.
Everything not matched is denied.

### firestore.rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isOwner(uid) {
      return request.auth != null && request.auth.uid == uid;
    }

    function isId(id) {
      return id is string && id.matches('^[A-Za-z0-9_-]{1,64}$');
    }

    function isCat() {
      let d = request.resource.data;
      return d.keys().hasOnly(['name', 'updatedAt'])
        && d.keys().hasAll(['name', 'updatedAt'])
        && d.name is string
        && d.name.size() <= 100
        && d.updatedAt == request.time;
    }

    function isEncounter(uid) {
      let d = request.resource.data;
      return d.keys().hasOnly(['catId', 'photoId', 'takenAt', 'type', 'updatedAt'])
        && d.keys().hasAll(['catId', 'takenAt', 'updatedAt'])
        && isId(d.catId)
        && existsAfter(/databases/$(database)/documents/users/$(uid)/cats/$(d.catId))
        && (!('photoId' in d) || isId(d.photoId))
        && d.takenAt is timestamp
        && d.takenAt > timestamp.date(2000, 1, 1)
        && d.takenAt < request.time + duration.value(1, 'd')
        && (!('type' in d) || d.type in ['seen', 'fed', 'unwell', 'kittens', 'ear_tipped'])
        && d.updatedAt == request.time;
    }

    match /users/{uid}/cats/{catId} {
      allow read: if isOwner(uid);
      allow create, update: if isOwner(uid) && isId(catId) && isCat();
      allow delete: if isOwner(uid);
    }

    match /users/{uid}/encounters/{encounterId} {
      allow read: if isOwner(uid);
      allow create, update: if isOwner(uid) && isId(encounterId) && isEncounter(uid);
      allow delete: if isOwner(uid);
    }
  }
}
```

Notes: `existsAfter` (not `exists`) so a new cat and its first encounter can go in one
batch. Each encounter write costs one extra document read for that check, which is fine at
this scale. A new `EncounterType` needs its value added here and deployed before the app
ships it; older rules would reject the write.

### storage.rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/photos/{fileName} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow create, update: if request.auth != null
        && request.auth.uid == uid
        && fileName.matches('^[A-Za-z0-9_-]{1,64}[.]jpg$')
        && request.resource.size > 0
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType == 'image/jpeg';
      allow delete: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

`[.]` avoids backslash escaping in the regex. `read` covers get and list of one's own folder.

## 4. Riverpod and the data layer

**Startup.** `main()` awaits `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
before `runApp`. An `appStartupProvider` (keepAlive FutureProvider) then: signs in
anonymously if there is no current user, runs the one-time import (section 6), and starts
the `PhotoUploader`. An `AppStartupWidget` shows a quiet loading state, or an error with
Retry, until it completes, then `CatsPage`. Retry is what the user sees on a first-ever
launch with no internet, because anonymous sign-in needs a connection once. After that, auth
persists offline.

**New providers** (all keepAlive, all overridable in tests):
- `firebaseAuthProvider`, `firestoreProvider`, `firebaseStorageProvider`: the SDK instances.
- `authRepositoryProvider` -> `AuthRepository { String? get uid; Stream<String?> uidChanges(); Future<String> signInAnonymously(); }`
  (later: `linkWith(credential)`, which keeps the same uid, so no data moves).
- `uidProvider` -> `String`: `ref.watch(appStartupProvider).requireValue`-gated current uid.
  Everything below it is only built after startup.
- `photoFileProvider(photoId)` -> `Future<File?>` (section 2).
- `photoUploaderProvider` -> `PhotoUploader` (application layer).

**CatRepository: from load/save-everything to stream plus targeted writes.**
```dart
abstract class CatRepository {
  Stream<List<Cat>> watchCats();                     // cats with their encounters
  Future<void> addCat(Cat cat);                      // new cat + its encounters, one batch
  Future<void> addEncounter(String catId, Encounter encounter);
  Future<void> renameCat(String catId, String name);
}
```
`FirestoreCatRepository(firestore, uid)` combines the two collection snapshots
(`Rx.combineLatest2` from `rxdart`) into `List<Cat>`; encounters whose `catId` has no cat
are ignored. Firestore mapping (Timestamp <-> DateTime, `type` <-> `EncounterType`) lives
here, not in the domain. `DeviceCatRepository` becomes `LegacyCatsReader`, used only by the
import.

**Write futures complete only when the server acknowledges**, so offline they wait. The
controller must not `await` them: call them with `unawaited(...)` and log errors (a
`permission-denied` there means a rules or app bug). Firestore shows local writes in the
listener at once, so the optimistic `state = AsyncData(...)` goes away.

**PhotoRepository** keeps `takePhoto()` and `discard()`; `File photoFile(String name)`
becomes the async `photoFileProvider(photoId)`. Remote access sits behind a thin
`PhotoStorage { Future<void> upload(String photoId, File file); Future<bool> download(String photoId, File to); }`
so the uploader and the provider are testable without Firebase.

**Domain.** `Cat` and `Encounter` stay as they are, except `Encounter.photo` (a file name)
becomes `photoId` (the stem); the local file is `'$photoId.jpg'`. `toJson`/`fromJson` stay
for reading the legacy file.

**Controllers.**
- `CatsController` becomes a stream notifier: `Stream<List<Cat>> build() =>
  ref.watch(catRepositoryProvider).watchCats();`. `rename` calls `renameCat`;
  `recordSighting` calls `addCat` or `addEncounter`, then `photoUploader.enqueue(photoId)`.
- `MeetCatController`, `MatchingService`, `WhoIsThisPage`: unchanged.
- `CatTile` and `CatCard` watch `photoFileProvider(e.photoId)` and pass the file (or null)
  to `CatPhoto`, which is unchanged.

**Tests stay fast.**
- Controller and widget tests keep using hand-written fakes: `FakeCatRepository` becomes an
  in-memory store that emits on a broadcast stream (`watchCats`) and records calls;
  `FakePhotoStorage` for the uploader; `uidProvider` overridden with `'test-uid'`. No
  Firebase plugin is loaded in these tests.
- `FirestoreCatRepository` gets its own tests with **`fake_cloud_firestore`** (dev
  dependency): pure Dart, supports snapshots, batches and server timestamps, so mapping and
  combining can be checked in milliseconds.
- **Skip `firebase_auth_mocks`**: `AuthRepository` is a thin wrapper, and everything above it
  is tested through an overridden `uidProvider`.
- **Rules: yes, test them on the Firebase Local Emulator Suite**, since they deploy as-is.
  A small Node suite in `app/rules-test/` using `@firebase/rules-unit-testing`, run with
  `firebase emulators:exec --only firestore,storage "npm test"`. Cases: owner can
  read/write, another uid and signed-out cannot, unknown fields, a long name, a bad type, an
  encounter for a missing cat, a cat and its first encounter in one batch, a non-JPEG or
  oversized photo, a bad file name.
- **No Flutter integration tests against the emulator for now.** The end-to-end check is a
  manual run on the Pixel (airplane mode on and off) before the first release with Firebase.

## 5. Packages

Add with `flutter pub add` so versions resolve at build time (Flutter 3.47, Riverpod 3):
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `rxdart` (combining the two snapshot streams)
- dev: `fake_cloud_firestore`

Tools: Firebase CLI (`firebase`), FlutterFire CLI (`dart pub global activate flutterfire_cli`).
`flutterfire configure` writes `lib/firebase_options.dart`, `android/app/google-services.json`
and the Gradle plugin lines; Firebase may need a higher Android `minSdk` (set what the build
asks for). These config files contain public client identifiers, not secrets, and are
committed. Security comes from the rules. Nothing else secret goes in the repo.

## 6. The one-time import

**Trigger.** Automatic, inside `appStartupProvider`, after sign-in: runs only if
`<documents>/cats/cats.json` exists. It blocks the app behind the startup screen until it
finishes, so no edits can happen between a partial run and a retry.

**Steps.**
1. Read `cats.json` with `LegacyCatsReader`. If it is missing but `.jpg` files exist, use
   today's rebuild-from-photos. If it is **corrupt, stop** and show an error (don't import
   a guess, and don't rename the file).
2. One batch (several if over 500 writes): `set` every cat at `cats/{cat.id}` and every
   encounter at `encounters/{encounter.id}` with `catId`, `photoId` (the file-name stem),
   `takenAt` (from `time`), `type`, and `updatedAt`. The ids are the ones already in the
   file, so a re-run rewrites the same documents with the same values: no duplicates.
3. Create an outbox marker for every referenced photo that exists locally. The photos stay
   where they are: `<documents>/cats/` is already the local photo store.
4. `await batch.commit()` with a 30-second timeout. On timeout (offline), show "Connect to
   the internet to bring your cats over" with Retry. The queued batch still syncs later, and
   a retry rewrites identical data.
5. After the commit is acknowledged, rename `cats.json` to `cats.json.imported` (kept as a
   backup and as the done marker). The import never runs again.

Photo uploads then drain in the background through the normal outbox. The local files are
never deleted: they are the cache. Verify on the Pixel: 7 cats in the app, the same
documents and photos in the console under David's uid, and a second launch does nothing.

## 7. Build checklist

**Worker A (data and app):**
1. Add packages; `main()` initializes Firebase; `firebaseAuthProvider`, `firestoreProvider`,
   `firebaseStorageProvider`, `AuthRepository`, `appStartupProvider`, `AppStartupWidget`.
2. `Encounter.photo` -> `photoId`; `FirestoreCatRepository` + new `CatRepository` interface;
   tests with `fake_cloud_firestore`.
3. `PhotoStorage` (Firebase), `PhotoUploader` + outbox, `photoFileProvider`; camera
   `maxWidth`/`imageQuality`; tests with fakes.
4. `CatsController` as a stream notifier, unawaited writes; `CatTile`/`CatCard` via
   `photoFileProvider`; update `FakeCatRepository`, `helpers.dart` and existing tests.
5. Import (section 6) with tests on a temp folder and the fake repository.
6. New l10n strings in `app_en.arb` and `app_es.arb` (startup loading, offline first launch,
   import needs internet, import failed).
7. Update `app/README.md` ("nothing is uploaded" is no longer true).

**Worker B (Firebase config and rules), in parallel with A:**
1. `app/firebase.json`, `app/.firebaserc`, `app/firestore.rules`, `app/storage.rules`
   exactly as in section 3; empty `firestore.indexes.json` (no composite indexes needed).
2. `app/rules-test/` emulator suite (section 4); all cases pass.
3. Once David has created the project: `flutterfire configure` for Android (and iOS if
   wanted), then deploy rules with David's go-ahead:
   `firebase deploy --only firestore:rules,storage`.

**Then:** `flutter analyze`, `flutter test`, a manual offline/online run on the Pixel, run
the import, an app screenshot per the Conventions, and commits on `main` with plain
sentences (for example "Keep the app's cats in Firebase", "Bring my cats over from the
phone").

**David does in the Firebase console (and his terminal):**
1. Create the Firebase project and upgrade it to Blaze; set a budget alert (a few dollars).
2. Pick locations (permanent): Firestore and Storage in the same region. A US region
   (`us-central1`) keeps Storage in the no-cost tier.
3. Create Firestore (production mode) and the default Storage bucket.
4. Authentication: enable the **Anonymous** provider. Do **not** turn on automatic clean-up
   of anonymous accounts.
5. `firebase login` on his Mac (his Google account), so `flutterfire configure` and deploys
   can run.
6. Optional later: App Check, API key restrictions to the Android app.

## 8. Risks and open questions

1. **An anonymous account is one phone install.** Uninstalling or clearing app data loses
   the uid, and with it access to the cats (the data stays, orphaned). Recommend linking
   David's account to a sign-in (Google) soon after import; linking keeps the uid. If the
   credential already belongs to another account, linking fails and data would need copying.
2. **First launch needs internet** (anonymous sign-in). Acceptable now; the screen says so.
3. **Rules are strict on purpose:** every new field or encounter type means deploying rules
   before the app release that uses it. Keep rules and app changes in the same commit.
4. **Photos over 10 MiB are rejected.** Old full-size Pixel photos are usually 2 to 6 MB. The
   import should log any that are too big; recompressing them is the fallback.
5. **Open:** which region (US for the free Storage tier vs closer to Mexico/Europe), and
   whether David wants Google sign-in linked before or right after the import.

## 9. Deviations made while building (Worker A)

- `CatRepository` also has `importCats(List<Cat>)` (batched in 500s), used only by the import.
- `appStartupProvider` builds its own `FirestoreCatRepository(firestore, uid)` for the import,
  since `catRepositoryProvider` needs `uidProvider`, which needs startup. `FirebasePhotoStorage`
  reads the uid lazily from `AuthRepository`, for the same reason (the uploader starts in startup).
- Import also runs, with no `cats.json`, when there are local `.jpg` files and no
  `cats.json.imported` (rebuild from photos); an empty folder imports nothing.
- Encounters in Firestore without a `photoId` are ignored when reading (the app needs a photo).
- `cantOpenCatsFolder` text now reads "Could not load your cats." (en/es).
- `photoFileProvider` goes through a `LocalPhotoCache` class so tests override one provider.
