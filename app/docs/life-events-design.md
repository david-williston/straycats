# Life events: entries in the cat's story

Status: the "build now" steps are built (steps 1 to 5, not the site pages; linking is not built). Builds on [firebase-design.md](firebase-design.md) and
[access-design.md](access-design.md). Replaces the one-tap status flag (`CatStatus`).

**Recommendation.** A life event (born, missing, found, sterilised, died) is a **dated entry in
the cat's story**, written by one person, in a new flat collection `users/{uid}/events/{eventId}`
next to `encounters`. Its date is a **string with its own precision** (`"2019"`, `"2019-03"`,
`"2019-03-14"`) plus an `around` flag. Events are **simply recorded**: nothing prevents, merges or
scores them. Nothing on the cat document says what state the cat is in; badges and sorting are
**derived** from the events (and encounters) by one pure Dart function. Born, sterilised and
died happen **once** in a cat's life: if a cat has more than one of the same once-only type (from
one person now, or from several people once records are linked), the app shows them all and a
gentle **"Possible conflict — check these"**, and people reconcile it themselves by editing or
deleting their own entry. The app never decides which is right. One person's entry changes only
their own record; nobody else's cat becomes "gone" because of it.

## 1. Data model

### Private events (build now)

```
users/{uid}/events/{eventId}
  catId      string   a cat in users/{uid}/cats
  type       string   born | missing | found | sterilised | died
  on         string   "YYYY" | "YYYY-MM" | "YYYY-MM-DD"   as precise as the person knows
  around     bool     optional; only with "YYYY": "around 2019"
  note       string   optional; the person's own words, at most 1000 chars, never an address
  createdAt  timestamp server time, set once
  updatedAt  timestamp server time
```

**Once-only vs repeatable** is a property of the type in Dart (`LifeEventType.onceOnly`), not of
the data or the rules: `born`, `sterilised`, `died` are once-only; `missing`, `found` repeat.

**Why not reuse encounters.** An encounter is a moment someone met the cat: a photo, an exact
`takenAt`, an area, observations; the app ignores encounters without a photo. An event has no
photo, often no exact day, no place, and it is a statement rather than an observation. Two
collections, one timeline in the UI.

**Why the date is a string.** A timestamp plus a `precision` field invites time-zone bugs ("March
2019" stored as 1 Mar 00:00 UTC is 28 Feb in Mexico). An ISO prefix is calendar-only, sorts as
text, is validated by one regex, and reads the same in rules, Dart and an export. In Dart:
`PartialDate {year, month?, day?, around}` with `start`/`end` (first and last day of the period)
and `format(locale)`.

**Sterilised, not neutered/spayed.** One type. The cat has no sex field today, so the screen says
"Sterilised" (ES uses the noun "Esterilización", which has no gender; section 4). If a sex field is added
later, the same event is *shown* as "Neutered" or "Spayed"; no data change. **Ear-tipped stays an
encounter condition**: it is evidence of sterilisation, not an event. Recording an encounter with
`ear_tipped` on a cat with no `sterilised` event offers, once, "Add sterilisation to the story?
(date unknown → year, around)". Nothing is created automatically.

**No place on events.** "Last seen near the market" lives in the note, with the existing "please
don't write an address" help. The cat's areas come from its encounters. If missing alerts later
need a last-seen area, add the encounter's `area` (geohash-6) and `neighbourhood`, never a point.

**IDs.** Client-made (`<millis>`), so events work offline. Deleting a cat deletes its events in
the same batch as its encounters. "Who recorded it" is the path's `uid`.

### When records are linked (later)

Linking is a human-confirmed `links/{linkId}` with `memberUids` and `records: {uid: catId}`
(access-design.md, section 2). Each member's events for the linked cat are copied in:

```
links/{linkId}/events/{uid}_{eventId}
  authorUid  string   == request.auth.uid
  type, on, around, createdAt, updatedAt     copied from the private event
  note       string   only if the author chose to share it
links/{linkId}/lastSeen/{uid}
  on         string   "YYYY-MM-DD", the member's latest encounter date (no photo, no area)
```

- **Written by the client in the same batch as the private event** (rules check membership), so it
  works offline and needs no Function. The id `{uid}_{eventId}` makes the copy idempotent; editing
  or deleting the event edits or deletes the copy. On linking, the app back-fills that cat's
  existing events (asked once: "Share Ninja's story with the people you've linked with?").
- Each member's phone runs the **same derive function** over everyone's events and `lastSeen`. A
  conflict between two people looks exactly like a conflict within one record, with names.
- Functions come later, only to reach people (tell members about a new entry; missing alerts).

## 2. Deriving what the app shows

One pure function, `lifeOf(events, sightings, {viewerUid}) -> LifeView`, tested without Firebase.
`events` are your own now, everyone's in a link later; `sightings` are encounter dates (your own
now, plus `lastSeen` later). Sort key: `on.start`, ties by `createdAt`.

1. **Once-only types.** For `born`, `sterilised`, `died`: none, one (shown plainly), or several →
   all shown, plus a `Conflict` on that type. Different dates, or the same date twice, both count;
   the people involved tidy it up. Several `sterilised` entries are a conflict only if their dates
   differ (two people recording the same op is agreement, not news); same for born and died when
   the periods overlap. Simple rule: *overlapping periods agree, disjoint periods conflict.*
2. **State.** The latest of `missing` / `found` / `died` decides the badge: `missing` → "Missing
   since …" (sorted first); `found` → "Found …" for 30 days, then nothing; `died` → remembered
   (sorted last). If any `died` exists, the cat is remembered, whatever comes after it, and
   anything after it is a conflict (next point).
3. **Sightings and found after a death.** An encounter (or a member's `lastSeen`) or a `found`
   after the *end* of a `died` period ("died in 2024" vs a photo in March 2024 is no conflict) is
   a `Conflict`: "There's a sighting on 2 Mar 2026, after this cat was recorded as having passed
   away. Is one of them wrong?" with *Edit the entry*, *Move the sighting to another cat*, *Leave
   it*. The death is never silently overridden, and the sighting is never hidden.
4. **Sighting after missing** is not a conflict, just a nudge: "Seen on 12 Nov. Found?" (one tap
   records `found` on that date).
5. **Conflicts are gentle and dismissable** per person (stored locally, keyed by the entries
   involved; a new entry brings it back). They never block recording anything.

**Linked view, extra:** each member's own grid still follows the derived view of the whole
story (so a death recorded by someone else does make the cat show as remembered, but it is shown
as theirs: "Recorded by Ana: passed away 16 Sep 2026"); a conflict lists whose entries disagree,
and only each author can change their own entry.

**Confirm / dispute (future idea, only if it stays simple):** a single "I know this too" on
someone else's entry, shown as "· Lucía agrees". No counts, thresholds or scoring; a dispute is
expressed by recording your own entry, which surfaces as a conflict.

## 3. What replaces the flag (delete, no migration)

No real cat has a status set, so nothing is migrated. Delete:
- `domain/cat_status.dart`; `status`, `statusSince`, `statusNote`, `withStatus` from `Cat`
  (`toJson`/`fromJson`, `==`, `hashCode`).
- `CatRepository.setStatus` and its Firestore and fake implementations; `CatsController.setStatus`.
- `cat_status_section.dart`; `cat_status_badge.dart` becomes `LifeBadge`, driven by `LifeView`.
- In `firestore.rules`, `status`/`statusSince`/`statusNote` from `isCat()`; their cases in
  `rules-test/rules.test.mjs`; `test/.../cat_status_test.dart`; the `status*` strings in
  `app_en.arb`/`app_es.arb` (reusing the wording that fits).

`Cat` gains `List<LifeEvent> events`; `FirestoreCatRepository.watchCats` combines three snapshots
(cats, encounters, events). `byLastSeen` ranks by `cat.life.state`.

## 4. UI

**The story.** The card's history becomes one timeline, newest first, mixing encounter photos and
event rows: a small icon (search, home, medical, cake, heart), the date in its
own precision, the note, and "You recorded this" (later the nickname). A conflict shows as one
quiet banner above the entries involved, which get a thin outline. A remembered cat's card keeps
the "first met – passed away" line. The record stays open: encounters can still be added.

**Adding an event.** "Status" becomes **"Add to story"** → *Went missing*, *Found*, *Born*,
*Sterilised*, *Passed away*. One dialog: date with precision (segmented *Day / Month / Year*, plus
*Around* with Year), defaulting to today/Day for missing/found/died and Year + Around for born and
sterilised; no future dates; an optional note with type-specific help. If the cat already has
that once-only type **in your own record**, the sheet says so under the option ("Already in the
story: born around 2019") and the dialog opens on **"Change the date"** of that entry, with "Add
another anyway" as a small link. Nothing is forbidden. Tapping any event row offers *Edit* and
*Delete* (delete asks once). *Found* keeps the celebration. *Passed away* says "We're so sorry"
and never celebrates.

**Wording** (`{date}` formatted to its precision; Spanish uses verbs or nouns, so no gender):

| | EN | ES |
|---|---|---|
| died | Passed away 16 Sep 2026 | Falleció el 16 sep 2026 |
| tile, died | Remembered | En su memoria |
| missing | Missing since 3 Nov 2026 | Se perdió el 3 nov 2026 |
| found | Found 12 Nov 2026 | Apareció el 12 nov 2026 |
| born | Born around 2019 / Born March 2021 | Nació alrededor de 2019 / Nació en marzo de 2021 |
| sterilised | Sterilised in 2024 | Esterilización en 2024 |
| author, own | You recorded this | Lo registraste tú |
| author, other | Recorded by Ana | Registrado por Ana |
| conflict | Possible conflict — check these | Puede que no coincidan — revísalos |
| conflict, two dates | Two dates for when this cat passed away. Is one of them wrong? | Hay dos fechas de su fallecimiento. ¿Alguna está mal? |
| sighting after death | There's a sighting after this cat was recorded as having passed away. Is one of them wrong? | Hay una foto posterior a su fallecimiento. ¿Alguna de las dos está mal? |
| nudge after missing | Seen on 12 Nov. Found? | Visto el 12 nov. ¿Apareció? |
| ear-tip offer | Ear-tipped: add sterilisation to the story? | Oreja cortada: ¿añadir la esterilización a su historia? |
| future, agree | · Lucía agrees | · Lucía está de acuerdo |

"Died" appears only in data and code; screens say "passed away" / "falleció".

## 5. Firestore rules sketch

```
function isPartialDate(d) {
  return d.on is string
    && d.on.matches('^(19[89][0-9]|20[0-9]{2})(-(0[1-9]|1[0-2])(-(0[1-9]|[12][0-9]|3[01]))?)?$')
    && int(d.on.split('-')[0]) <= request.time.year()
    && (!('around' in d) || (d.around is bool && (!d.around || d.on.size() == 4)));
}
function isEvent(uid) {
  let d = request.resource.data;
  return d.keys().hasOnly(['catId', 'type', 'on', 'around', 'note', 'createdAt', 'updatedAt'])
    && d.keys().hasAll(['catId', 'type', 'on', 'createdAt', 'updatedAt'])
    && isId(d.catId)
    && existsAfter(/databases/$(database)/documents/users/$(uid)/cats/$(d.catId))
    && d.type in ['born', 'missing', 'found', 'sterilised', 'died']
    && isPartialDate(d)
    && (!('note' in d) || (d.note is string && d.note.size() <= 1000))
    && d.updatedAt == request.time;
}
match /users/{uid}/events/{eventId} {
  allow read: if canRead(uid);                                  // owner; admin read-only
  allow create: if isOwner(uid) && isId(eventId) && isEvent(uid)
    && request.resource.data.createdAt == request.time;
  allow update: if isOwner(uid) && isEvent(uid)
    && request.resource.data.createdAt == resource.data.createdAt;
  allow delete: if isOwner(uid);
}
```

Rules do **not** enforce once-only: they can't count documents, and the model wants duplicates to
be visible, not refused. Years from 1980 (a cat first recorded late in life). Month/day "not in
the future" is checked in the app; rules check the year. Later, for links: `events` copies
create/update/delete only if `isMember(linkId)`, `authorUid == request.auth.uid` and the id starts
with `request.auth.uid + '_'`; `lastSeen/{rid}` only by `rid`. Admin: read only, everywhere.

## 6. Implementation steps

**Now (each ships alone; rules deployed before the app that uses them):**
1. **Domain:** `PartialDate`, `LifeEventType` (with `onceOnly`), `LifeEvent`, `LifeView` and
   `lifeOf`, with tests: precision, around, sorting, overlapping vs disjoint periods, a second
   death, a sighting after the end of a death period, missing then sighting.
2. **Rules:** the `events` block + emulator tests (owner, admin read-only, other uid denied, bad
   type/date/around/note, event for a missing cat, cat + event in one batch, createdAt immutable).
3. **Data:** events in `FirestoreCatRepository` (watch, add, update, delete; deleted with the
   cat), fake repository, `fake_cloud_firestore` tests.
4. **Replace the flag:** "Add to story" sheet with "Change the date" for an existing once-only
   entry, the date-with-precision dialog, event rows in the card timeline, `LifeBadge` on tile and
   card, `byLastSeen` from `LifeView`; delete everything in section 3, including the status fields
   in `isCat()`; EN/ES strings. App screenshot per the Conventions.
5. **Conflicts and nudges:** the banner, the sighting-after-death question, "Seen … Found?", and
   the ear-tip offer.
6. **Site:** cat-identity and when-a-cat-goes-missing can say life events are entries in the
   story, and conflicts are shown, not settled (both languages, `updated:` dates).

**When linking arrives:**
7. `links` with membership (access-design.md); event copies written alongside private events,
   back-fill on link, `lastSeen` on new encounters; `lifeOf` over everyone's entries with names.
8. Optional: "I know this too". Functions to tell members about new entries, and missing alerts.

## 7. Decisions (David)

1. **Someone else's death in a linked record** shows only in the story until you agree. It does
   not put the cat in the remembered group of your grid. (Linking is not built yet.)
2. **Wording:** "Passed away" / "Falleció" on screen, "Remembered" / "En su memoria" on the tile.
3. **The ear-tip offer** is welcome: offered once per cat, and it never adds anything by itself.
4. **A missing entry keeps the last-seen coarse area:** optional `area` (geohash-6) and
   `neighbourhood`, captured exactly like encounters: a `CoarseArea` only, the `assertCoarse`
   guard before every write, coarse permission only, never exact coordinates. (Built: the area is
   taken from the cat's latest encounter that has one, so nothing new is read from the phone.)
5. **Linked notes** are chosen per entry (future; no UI now).

## 8. Notes on what was built

- Timeline: one horizontal strip on the card, newest first, with encounter cards and entry cards.
- Once-only conflicts follow the simple rule (overlapping periods agree, disjoint periods
  conflict), so "Sterilised 2024" and "Sterilised March 2024" are not flagged.
- Not built yet: dismissing a conflict per person, the "Move the sighting" / "Leave it" actions
  on the sighting-after-death question (the entry itself can be edited or deleted), the site
  pages (step 6), the app screenshot, and everything under "When linking arrives".
