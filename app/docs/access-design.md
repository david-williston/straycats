# Who can see what: roles and access

Status: design, not built. Builds on [firebase-design.md](firebase-design.md). Nothing here
changes the rules or the app yet.

**Recommendation.** Keep the data where it is: `users/{uid}/…` stays one person's private
record, readable by its owner and, from now on, by an **admin**. Admin is a **Firebase custom
claim** (`admin: true`), set by a small Admin SDK script run from David's Mac. The script also
writes a `roles/{uid}` doc as the readable record of who holds which role. Rules check only the
claim, which costs no reads in Firestore or Storage. Before the claim is set, David's account is
**linked to Google sign-in** (`linkWithCredential`, same uid), so it survives a reinstall. Admin is
**read-only** in the app. Repairs go through scripts, and nobody edits another person's
record. Everything that is ever *shared* (care networks, missing-cat alerts, links between
records, cards) goes in **new top-level collections whose access comes from membership docs**,
filled with copies (projections) that the owner chooses to share. Private trees are never opened
to other people. Global roles stay few (admin now, perhaps moderator later). A researcher never
gets a role: researchers get anonymised exports.

## 1. Global roles: custom claims, a Firestore doc, or both

| | Custom claim | `roles/{uid}` doc read in rules |
|---|---|---|
| Cost in rules | free (`request.auth.token.admin`) | one `get()` per request, which counts toward the 10/20 access-call limit |
| Storage rules | free | `firestore.get()` cross-service read: billed, slower, needs the Storage service agent's IAM grant |
| Takes effect | on the next token refresh (up to 1 h, or at once with `getIdToken(true)`) | at once |
| Revoke | remove claim + `revokeRefreshTokens`; an ID token already issued lasts ≤ 1 h | at once |
| Who can grant | Admin SDK only (tamper-proof) | whoever the rules allow to write the doc |
| Listable / auditable | no (you can't query claims) | yes |

**Use both, with one job each.** The **claim** is what the rules enforce. **`roles/{uid}`** is the
record: `{admin: true, grantedAt, grantedBy, note}` plus an append-only `roles/{uid}/history/{id}`.
Clients can't write it, and the rules never read it. The same script writes both, so they stay
in step. For one admin, waiting up to an hour for a revoke to take effect is fine. If there are
many staff later, they can move to doc-based checks (or claims plus an `auth_time` check
against a revocation doc) without changing the data.

**Granting.** `app/tools/roles/set-role.mjs <uid|email> admin on|off --note "…"` uses
`firebase-admin` with Application Default Credentials (`gcloud auth application-default login`,
quota project `straycats-love`). **No service-account key file**, so there is nothing secret in the
repo. It refuses a uid with no non-anonymous provider, and it prints the result. A Cloud Function
for this is not worth it until someone other than David grants roles.

**Which roles, and why so few:**
- **admin** (now): David. Reads everything, writes nothing through the app.
- **moderator** (when shared features exist): acts on *shared* collections only (reports,
  alerts, disputed links), never on `users/{uid}`. A claim `moderator: true`.
- **verified** (later, maybe): "trusted rescuer/caretaker/vet" from the privacy page. It's a fact
  about a person that a human checked, not a grant of access. It might unlock creating a network
  or seeing a finer area *inside* a network the person already belongs to.
- **No `support` role** (admin covers it), and **no `researcher` role**. Anonymised datasets are
  produced by an export job (Admin SDK or BigQuery export, then coarsened and aggregated) and
  published as files. Raw records never get a research audience.

## 2. Resource-level access: membership, not roles

Roles answer "what may this person do anywhere". Every future feature on the site asks "what
may this person do *with this cat or this group*", which a global role can't express (claims are
limited to 1000 bytes and can't hold per-network lists). So: **membership docs on the shared
resource**, checked with `exists()`/`get()` (one read each). Each feature below gets its own
top-level collection, filled by the owner's explicit choices, never by reading another person's
`users/{uid}`.

| Feature (site page) | Collection | Who can read / write |
|---|---|---|
| Care network (care-network) | `networks/{nid}`, `networks/{nid}/members/{uid}` `{role: organiser\|caretaker\|vet, joinedAt}`, `networks/{nid}/updates/{id}` ("fed today", "looks thin") | members read. Members add updates. Organisers manage members. A vet is a member with `role: vet`, not a global role |
| Shared photo in a network | Storage `networks/{nid}/photos/{photoId}.jpg`, a copy the owner chose (EXIF stripped) | Storage rule: `firestore.exists(…/members/$(uid))`. Not a download URL |
| Linking records "your Ninja is my Güero" (cat-identity, lost-and-found) | `links/{linkId}` `{memberUids:[a,b], records:{a: catId, b: catId}, proposedBy, status}` | the two people. One proposes, the other confirms. Neither can read the other's record, only the card each chooses to show |
| Card / follow (meeting-a-cat) | `cards/{cardId}` (name, coat, area, chosen photo copy), `cards/{cardId}/followers/{uid}` | owner writes. Followers read. A link for someone without the app needs a Function (no public photo URLs) |
| Missing-cat alert (when-a-cat-goes-missing) | `alerts/{aid}` (card snapshot, coarse area, status), `alerts/{aid}/recipients/{uid}`, `alerts/{aid}/sightings/{id}` | **needs Cloud Functions**: the server picks the recipients (people linked to the cat or in the area), so the person who raised the alert never learns who has met the cat. Recipients read the alert and add sightings. Only the searchers read sightings |
| "Is this the same cat?" across people | a server-built index (`catIndex`, coarse area + features) | Functions only. Clients never query other people's encounters |

Membership docs keyed by uid make "am I a member" one `exists()`. "My networks" is a
collection-group query on `members` filtered by a `uid` field (one index exemption). Each new
shared collection gets its own rules block. Nothing needs restructuring.

## 3. Data layout: keep `users/{uid}/…`

**Recommendation: keep the nested layout.** Moving to top-level `cats`/`encounters` with
`ownerUid` would be nearly free now, but it buys nothing the plan above needs:
- **Ownership comes from the path.** The rules never trust a field. A top-level layout has to
  enforce `ownerUid == auth.uid` on create and keep it immutable on update, and **every client
  query must filter on `ownerUid`** or it is denied ("rules are not filters").
- **Admin needs no collection-group query.** `FirestoreCatRepository(db, uid)` already takes a
  uid, so "this person's cats" in admin mode is the same repository with someone else's uid. A
  collection-group rule (`match /{path=**}/cats/{id}`) stays available if overview counts are ever
  wanted.
- **Shared data is a projection anyway** (section 2). The one thing a top-level layout does
  better, querying everyone's encounters together, is exactly what the privacy rules forbid
  clients to do. The server can still do it with the Admin SDK.
- **Deleting or exporting a person's data** is one subtree, in Firestore and in Storage
  (`users/{uid}/photos/`), which also suits the "Delete User Data" extension.
- The offline cache is the same either way.

**Two small changes:**
1. **Create the `users/{uid}` doc** `{createdAt}` (written once at startup, after sign-in). Today
   it's a phantom parent, which queries don't return, so an admin can't list people. Keep it
   minimal: no email, no device info. A nickname can go here later.
2. **Reserve the names `cats` and `encounters`** for private records. Shared collections use other
   names (`networks/{nid}/sharedCats`, not `…/cats`), so a future collection-group rule on `cats`
   never reaches shared data by accident.

**Storage** stays `users/{uid}/photos/{photoId}.jpg`. Admin reads are a claim check, which is free.
Shared photos are separate copies under the shared resource's path. A membership check there
costs one `firestore.exists()` per request, which is fine because each shared photo is
downloaded once and then cached. On the first deploy that uses it, the console asks to grant the
Storage service agent access to Firestore.

## 4. Admin in the app now

**Durable identity first.** An anonymous uid disappears with the install. Add "Sign in with
Google to keep your cats" (`google_sign_in` + `GoogleAuthProvider.credential`):
- **Signed in anonymously** → `currentUser.linkWithCredential(cred)`. The uid stays the same, so no
  data moves.
- **`credential-already-in-use`** (a reinstall, or a second phone) → `signInWithCredential(cred)`.
  This returns the original uid and its cats. If the throwaway anonymous uid already has cats,
  say so rather than silently dropping them. (Merging them is a later feature.)
- Enable the Google provider. Add the debug and release SHA-1s for the Android app. Keep
  anonymous sign-in as the default way in (a nickname is enough to begin). On iOS, Apple's rule
  on offering an equivalent sign-in needs checking before release.

**Claim then app.** Run `set-role.mjs david@… admin on`, then the app calls
`getIdTokenResult(true)` once (on startup when online, and from a hidden "refresh" in settings).
`isAdminProvider` reads `claims['admin'] == true`. The app hides the admin UI otherwise, but
**the rules are the security**. The UI is just convenience.

**Read-only by default.** Rules give admin `read` only. Each person keeps their own record, so
the admin doesn't rename someone's cat. A real repair (a corrupt doc, an abuse takedown) is a
reviewed Admin SDK script run from the Mac, which leaves a trace in the shell and in git. David
writes his *own* cats as an owner, unchanged.

**App shape.** A "People" screen (admin only) lists `users`, each with created date and cat count.
Tapping one opens their cats through `FirestoreCatRepository(db, thatUid)`, read-only, with a
banner ("Viewing someone else's cats"). Three things to get right:
- `PhotoStorage` and `photoFileProvider` must take the **owner uid**. Today they use the current
  user's uid.
- Other people's photos go to a **separate, evictable cache** (`<cache>/admin/{uid}/`), never
  `<documents>/cats/` (that is the outbox and the never-evicted store). Photo ids are millis, so
  two people's ids can collide.
- Use one-off `get()`s rather than long-lived listeners for other people's data, and clear the
  admin cache on sign-out. This keeps other people's records from piling up on the phone.

**Logging admin access, honestly.**
- *Without Functions:* the app can write `adminAccess/{id}` `{adminUid, targetUid, action, at}`
  (rules: create only by admin, `at == request.time`, no update or delete). It's a useful diary,
  but **it can't be enforced**: rules can require a log write alongside a *write*, never alongside
  a *read*. A modified client skips it. Also worth checking: whether Cloud Audit Logs (Data
  Access, for Firestore and Cloud Storage) record client-SDK reads for this project. If they do,
  turning them on is the only tamper-proof record that needs no code. It costs Logging volume.
- *With Functions (later, for a second admin or real users):* remove direct admin `read` from the
  rules. Admin views go through callable Functions that check the claim, **write the log entry
  server-side, then return the data**. Reads are then logged without exception. The same Functions
  are needed for alerts, cards for people without the app, EXIF stripping and deleting accounts.
- Be honest about the limit: the project owner can already read everything in the Firebase
  console, and that can't be removed from the owner. In-app admin adds convenience, not power.

## 5. What the privacy page should say

Add to the site (both `.md` and `.es.md`), plainly:
- What's stored: the cats you've met, your names for them, the details you add, your photos,
  when you took them. No exact location is stored today, and none will ever be shown to others.
- **Who can see it:** you. And David, who runs Stray Cats, can see everything stored, to fix
  problems and keep the service working. Nobody else can. If more people are ever given access
  (for example moderators), the page will name the role, what it can see, and that access is
  logged, before it happens.
- Photos are never public and never have shareable links. Sharing, when it comes, will always be
  something you choose, cat by cat.
- Where it lives (Google Firebase, the region chosen), and how to ask for your data to be deleted.

## 6. Migration steps (each one ships on its own)

1. **Google sign-in, linked.** `AuthRepository.linkWithGoogle()`, the already-in-use fallback,
   settings entry, l10n strings (en and es), SHA-1s. Test on the Pixel: link, reinstall, sign in,
   and the same 7 cats come back.
2. **Profile doc.** Write `users/{uid}` `{createdAt}` at startup. Add the rule and tests. Deploy the
   rules first, then the app.
3. **Grant script.** `app/tools/roles/set-role.mjs` (claim + `roles/{uid}` + history), plus a README.
   Run it for David. No app change.
4. **Admin read in rules.** Add `isAdmin()` to the Firestore rules (users, cats, encounters, roles)
   and the Storage rules. Rules tests: admin reads others, admin can't write others,
   non-admin denied, no one writes `roles`. Deploy.
5. **Admin screens.** `isAdminProvider`, the People list, a read-only cats view, owner-uid-aware
   photo loading, a separate cache. Then an app screenshot per the Conventions.
6. **Access diary (optional).** `adminAccess` writes, plus a check on Cloud Audit Logs.
7. **Privacy page** (site, both languages, with `updated:` dates).
8. *Later, as needed:* Functions for logged admin reads, alerts, cards, EXIF-stripped photo copies.
   Then `networks`/`links` with membership rules, and a `moderator` claim.

## 7. Draft rules (access parts only; `isCat`/`isEncounter` unchanged)

```
// firestore.rules
function signedIn() { return request.auth != null; }
function isOwner(uid) { return signedIn() && request.auth.uid == uid; }
function isAdmin() { return signedIn() && request.auth.token.admin == true; }
function canRead(uid) { return isOwner(uid) || isAdmin(); }

match /users/{uid} {
  allow read: if canRead(uid);                       // admin may list all people
  allow create: if isOwner(uid)
    && request.resource.data.keys().hasOnly(['createdAt'])
    && request.resource.data.createdAt == request.time;
}
match /users/{uid}/cats/{catId} {
  allow read: if canRead(uid);
  allow create, update: if isOwner(uid) && isId(catId) && isCat();
  allow delete: if isOwner(uid);
}
match /users/{uid}/encounters/{encounterId} {
  allow read: if canRead(uid);
  allow create, update: if isOwner(uid) && isId(encounterId) && isEncounter(uid);
  allow delete: if isOwner(uid);
}
match /roles/{uid} {                                 // written only by the Admin SDK
  allow read: if canRead(uid);
  match /history/{id} { allow read: if isAdmin(); }
}
match /adminAccess/{id} {                            // optional diary (step 6)
  allow read: if isAdmin();
  allow create: if isAdmin() && request.resource.data.adminUid == request.auth.uid
    && request.resource.data.at == request.time;
}
// Future hook: membership on a shared resource, never on users/{uid}.
// function isMember(nid) { return signedIn() && exists(
//   /databases/$(database)/documents/networks/$(nid)/members/$(request.auth.uid)); }
// match /networks/{nid} { allow read: if isMember(nid) || isAdmin(); … }
```

```
// storage.rules
function isAdmin() { return request.auth != null && request.auth.token.admin == true; }
match /users/{uid}/photos/{fileName} {
  allow read: if request.auth != null && (request.auth.uid == uid || isAdmin());
  // create/update/delete unchanged: owner only
}
// Future: match /networks/{nid}/photos/{fileName} { allow read: if request.auth != null &&
//   firestore.exists(/databases/(default)/documents/networks/$(nid)/members/$(request.auth.uid)); }
```

**Risk to check now:** the camera, and `image_picker`'s resize, may keep **EXIF GPS** in the
photos. That's harmless while only the owner and the admin see them. Any copy that is ever
shared must be re-encoded without EXIF, and it would be better still to strip EXIF at capture.

## 8. Open questions for David

1. Is admin read-only in the app right, with repairs done only by scripts from the Mac?
2. Google only, or also Apple (iOS) or an email link, for durable sign-in?
3. Is a client-written access diary worth having, or wait for Functions plus audit logs?
4. Should the `users/{uid}` doc hold a nickname now (the site says a nickname is enough to begin)?
5. Is anyone likely to need moderator or admin access in the next few months? That decides when
   Functions arrive.
