# Cross-person matching: "someone nearby may know this cat too"

Status: design, not built. Builds on [firebase-design.md](firebase-design.md),
[access-design.md](access-design.md) (the "Is this the same cat?" `catIndex` row, links) and
[life-events-design.md](life-events-design.md) (what a link does once it exists).

**Recommendation.** Matching is **event-driven and local**. When an opted-in person saves an
encounter with a photo, the phone crops the cat and computes a **fingerprint** (an embedding) on
the device and drops it into a write-only inbox. One Cloud Function (2nd gen) files it in a
server-only `matchIndex` and asks Firestore vector search for the nearest fingerprints **in the
same geohash-6 cell and its 8 neighbours**, one equality-filtered query per cell. Each fingerprint
is compared once, when it arrives. Whichever of two photos of the same cat comes second finds the
first, so **no periodic or dirty-cell job is needed**. Cost follows local density and new photos,
never the total number of cats. The fingerprint is a **candidate generator, tuned for precision**:
a pair becomes a suggestion only on strong or repeated evidence. Each person is then asked *same
cat?* with nothing about the other person shown. If both say yes, the app opens a **private chat
between the two nicknames** and reveals nothing else. From there the people decide everything
themselves (section 7). If fingerprints prove too weak, the fallback is a human one: "ask the
neighbours", started by the person (section 8).
**Nothing is shown to anyone until an offline evaluation on David's own cats and a shadow run
pass a go/no-go bar.**

## 1. Will a photo fingerprint work? (David's concern, head-on)

Probably only partly, and the design assumes that. What is known:
- **General models are weak at telling individuals apart.** The WildlifeDatasets paper found
  DINOv2 and CLIP well behind MegaDescriptor, a model trained for animal re-ID, on re-ID
  benchmarks [1]. General embeddings capture "orange cat, lying down, on tiles" more than "this
  orange cat".
- **Cat faces are hard even for specialised models.** PetFace (ECCV 2024, 257k individuals in 13
  families, cats included) reports average top-1 identification of only about 51–54% for the best
  models, in a closed set with clean face crops [2]. Street photos (side views, backs, night, a
  cat half behind a pot) will do worse.
- **Pose and light** move an embedding more than identity does. The same cat seen from the front
  and from behind can be further apart than two tabbies seen from the front.
- **Hard cases:** solid black (almost no pattern, and exposure changes everything), solid or
  mostly orange, grey, and littermates with near-identical coats. Easy cases: calico,
  tortoiseshell, tuxedo and bicolour with irregular patches, and tabbies photographed from the
  side.

**Mitigations, all in this design:**
1. **A gallery per cat, not an average.** Every encounter keeps its own fingerprint, and a
   candidate cat's score is its *best* match (plus how many of its encounters support it).
   A front view finds the front views. Averaging would blur the angles into a mush.
2. **A detector crop first** (section 2), so the background (the same garden, the same floor)
   doesn't make two different cats look alike. It also hides the surroundings, which helps privacy.
3. **Body pattern and face are separate signals.** Version 1 uses the body crop. A face crop and
   face embedding are added only if the evaluation shows they help.
4. **Coat as a veto, not a filter.** An optional coat (hair: short or long; colour: black, white,
   grey, orange, tabby, calico/tortoiseshell or mixed; each can be "Not sure") drops pairs that
   clearly conflict (black vs calico). It is never required and never decides a match, because a
   wrong label would hide true matches.
5. **The prior: area and time.** Candidates come only from the 9 cells. A pair whose sightings
   are years apart needs a stronger score.
6. **Evidence accumulates.** One very strong photo pair, or two good ones on different days,
   before anything is suggested (section 4).
7. **Hard coats get stricter thresholds**, or no suggestions at all. A solid black cat may never be
   suggested from photos alone, and that is acceptable: the fallback (section 8) still works for it.

The design aims for **few, good suggestions**. A missed match costs nothing (people can still
link by hand later). A wrong one costs trust and shows someone a stranger's cat.

## 2. The on-device model

**Pipeline:** photo → **cat detector** (crop the largest cat box, plus 10% margin; this also
gives the "a real cat in every photo" check from open-data-and-tech) → **embedder** (224×224)
→ L2-normalised float vector. It runs after save, in the background, offline. The fingerprint is
cached on the phone and uploaded only when matching is on.

| | Detector | Embedder A (recommended) | Embedder B (fallback) | Excluded (licence) |
|---|---|---|---|---|
| Model | EfficientDet-Lite0 (COCO, has `cat`), MediaPipe Object Detector | **DINOv2 ViT-S/14**, converted to LiteRT (ai-edge-torch), int8 | MediaPipe Image Embedder (MobileNetV3) | MegaDescriptor-T-224 (Swin-T, animal re-ID) |
| Size | ~4.4 MB | ~22 MB int8 (21M params) | ~4–10 MB | ~28M params, ~30 MB int8 |
| Vector | boxes | 384-d | ~1024-d (check) | 768-d (check) |
| Pixel 9 | ~20 ms | ~50–150 ms | ~10–30 ms | ~100–200 ms |
| Low-end (4×A53) | ~100 ms | ~0.5–1.5 s | ~100 ms | ~1–2 s |
| Licence | Apache-2.0 | Apache-2.0 | Apache-2.0 | **CC BY-NC 4.0** [3] |

**Recommendation: DINOv2-small**, because its licence is clean, its 384 dimensions sit well under
Firestore's 2048 limit, and it is the strongest general backbone at that size. **Fallback:
MobileNetV3** (tiny, fast, weaker). **Licence rule (decided 13 Nov):** only free models under a
permissive licence (Apache-2.0 or MIT). Non-commercial models are excluded, not just outranked.
That rules out MegaDescriptor-T (built for re-ID [1], but CC BY-NC [3]), even though it would be
the one to beat on accuracy. MiewID (EfficientNetV2, 51M params, 440 px) is too big for phones and
its licence isn't stated [4].
The timings are estimates to measure on the Pixel 9 and on a cheap phone. Latency doesn't matter
much, because nothing waits on it. To keep the app small, the model can be **downloaded once
when matching is switched on**.

## 3. Data layout

```
users/{uid}/fingerprints/{encounterId}     client: create only; nobody reads (not even admin)
  embedding   list<number>  384 floats, L2-normalised
  model       string        "dinov2s-v1" (a different model never compares with this one)
  createdAt   timestamp     == request.time
matchIndex/{uid}_{encounterId}             server only (Admin SDK); rules: no client access
  uid, catId, encounterId
  area        string        geohash-6 of the encounter (copied from the encounter, not the inbox)
  coatHair    string?       optional veto attribute: short | long
  coatColour  string?       optional veto attribute: black | white | grey | orange | tabby | calico/tortoiseshell | mixed
  takenAt     timestamp
  embedding   vector(384)   FieldValue.vector; composite vector index (area ASC, embedding flat)
  model       string
  expireAt    timestamp     takenAt + 3 years (a Firestore TTL policy keeps the index local in time)
matchPairs/{pairId}                        server only; pairId = sha256(sorted "uid/catId" x2)
  sides       {a: {uid, catId}, b: {uid, catId}}
  evidence    list of {encA, encB, sim, day}, at most 10
  stage       candidate | suggested | chat | closed     (chat = both said yes)
  answers     {uidA: yes|no|unsure, uidB: ...}
  closedReason declined | expired | deleted | blocked | left
users/{uid}/suggestions/{pairId}           server writes; the owner reads, and updates only `answer`
  catId       own cat only     encounterId  own photo that triggered it
  stage       suggested | chat | closed
  answer      yes | no | unsure | null     answeredAt timestamp
```

- **Hand-over: a write-only inbox, not a callable.** A Firestore write is queued offline and
  retried by the SDK, like everything else in the app. A callable needs a network at that moment.
  Rules: `allow create: if isOwner(uid) && isId(encounterId) && embedding is list &&
  size() == 384 && model in [...] && optedIn` (the opt-in is a `matching: true` field on
  `users/{uid}`). `allow read, update, delete: if false`. The Function deletes the inbox doc
  once it is filed.
- **Nobody can read another person's fingerprints.** `matchIndex` and `matchPairs` have no
  client rules at all, so access is denied. Admin is read-only *in the app* and gets nothing here
  either: embeddings are useless to read and close to a photo (next point).
- **Embeddings can leak photos.** Inversion attacks on DINO/CLIP-style features rebuild rough
  images. So fingerprints are treated **like photos**: computed on the cat crop only, never
  exported in open data, and deleted with their encounter. Per-encounter storage (the gallery) is
  needed for accuracy. An average would leak less, but it matches badly.
- **Each person sees only their own side.** The pair doc holding both uids is server-only. Each
  person gets their own `suggestions` doc, with only their own `catId`. Rules can't hide fields,
  so splitting the docs is the only safe way.

## 4. The matching function

**Trigger:** `onDocumentCreated("users/{uid}/fingerprints/{encounterId}")`, in the Firestore
region.
1. **Check:** opted in; the encounter exists, has a `photoId` and an `area`; its photo exists in
   Storage; the per-person caps aren't exceeded (section 6). Otherwise delete the inbox doc and
   stop.
2. **File:** `set` `matchIndex/{uid}_{encounterId}` (idempotent, because a deterministic id
   overwrites itself on retry). Then delete the inbox doc. If this cat has more than 12 entries,
   drop the entry most similar to another of its entries. That keeps different angles, not just
   the latest.
3. **Query:** for each of the 9 cells (`geohashNeighbours` + the cell itself, ported to TS),
   `where('area','==',cell).findNearest({vectorField:'embedding', queryVector, limit:10,
   distanceMeasure:'COSINE', distanceThreshold: 1 - T_low})`, in parallel. One query per cell
   rather than `in`: pre-filters need a composite vector index and allow no inequality [5][6], and
   `in` support isn't documented, so try it in the emulator and keep 9 queries if it isn't there.
   Same-person results and other models can't be pre-filtered with `!=`, so they are dropped in
   code.
4. **Score per candidate cat** `(uid', catId')`: best similarity, number of supporting entries,
   coat veto, and a time penalty (sightings years apart need more). Thresholds come from the
   evaluation (section 9), never guessed. Start from a precision of at least 0.9 on David's set,
   with a stricter `T` for `black`/`orange`/`grey` coats.
5. **Evidence:** add `{encA, encB, sim, day}` to `matchPairs/{pairId}` (a transaction, pair id
   deterministic). The pair becomes `suggested` only when one sim is at least `T_strong`, or two
   pairs on **different days** reach `T`. It also needs the top candidate to lead the next cat by
   a margin (like `suggestionLead` in `MatchingService`), neither side to be rate-limited, and the
   pair never to have been declined or blocked. **A declined pair is never suggested again.**
6. **Deliver after a random delay** of 2 to 36 hours (a Cloud Tasks / `onTaskDispatched` queue).
   That way a suggestion can't be tied to the moment the other person took a photo. Both
   `suggestions` docs are written in one batch.

**Answers:** `onDocumentUpdated("users/{uid}/suggestions/{pairId}")` records the answer in the
pair. If both answer `yes`, the stage becomes `chat`: the Function opens a private chat between
the two nicknames and nothing else (section 7). It creates no link. Either `no` closes the pair
for both. The other side sees only "This suggestion has closed", never who said no or why.
`unsure` keeps the pair open until a new photo adds evidence. Any suggestion with no answer
expires after 30 days.

**Clean-up** (all idempotent, run by triggers):
- **Encounter deleted:** delete `matchIndex/{uid}_{encId}`.
- **Encounter moved to another cat:** update `catId` in the index (`onDocumentUpdated`).
- **Cat deleted:** its encounters go in the same batch, so the index follows. Any open pair for
  that cat closes (`deleted`).
- **Matching switched off, or account deleted:** delete everything in `matchIndex` with
  `where('uid','==',uid)`, close every open pair and its chat, delete its suggestions. Existing
  `links` stay, because they are a separate human decision with their own unlink.
- **Model upgrade:** a new `model` value. The phone re-computes its fingerprints from local photos
  (it keeps all of them) and re-sends them, and old entries are deleted. Nothing mixes models.

## 5. Cost

**Prices** (Firestore Standard, regional, about): reads $0.03 per 100k, writes $0.09 per 100k,
storage $0.15 per GiB a month. Free every day: 50k reads, 20k writes. Functions free each month:
2M invocations. **A vector query is billed one read per 100 index entries scanned, plus one read
per document returned**, and at least one read even if it finds nothing [6].

**Per photo:** 9 queries. A typical urban cell + neighbours holds about 3,000 entries (30
entries per cell-neighbour of opted-in cats, 10 photos each), which costs 9 + 30 index reads, plus
about 10 returned docs, so about **50 reads**. A very dense area (a park colony, about 40k entries)
costs about 500 reads. Add about 5 writes and 2–3 invocations. That comes to about
**$0.00003 per photo** typically, and $0.0002 at worst. Storage per entry: about 3 KB of vector
plus the same again in the index, call it 7 KB.

| Cats (opted in) | Photos a month (~4/cat) | Matching a month | Index storage (≤12/cat) | Total a month |
|---|---|---|---|---|
| 1k | 4k | inside the free tier | 0.1 GB | ~$0 |
| 100k | 400k | ~$12 (dense: ~$80) | 8 GB, ~$1.20 | ~$15 |
| 1M | 4M | ~$120 (dense: ~$800) | 80 GB, ~$12 | ~$130–800 |

**Why it doesn't blow up:** each photo touches only its 9 cells, so cost is
`new photos × local density`. Doubling the cats in other cities changes nothing here. An
all-pairs scan of 1M cats × 12 entries reads 12M docs (about $4) *every run* before any compute,
and its comparisons grow with n². The safety valves: the 12-entry gallery cap, TTL expiry, the
per-person caps, and dropping to `limit: 5` if dense cells cost too much. If vectors ever
dominate, a 128-d PCA projection cuts storage by 3×.

## 6. Abuse and safety

**Threats:** using matching to find where a person lives or feeds cats, stalking someone through
their cat, harvesting who has cats where (also by remote probing: the area and the embedding
are both claimed by the client), and fake fingerprints.

**Mitigations:**
- **Nothing locates anyone.** No cell, distance, map or date of the other person's sightings is
  ever shown, even after linking. Only cells are stored, so nothing finer exists to leak.
- **The fingerprint must come with a real photo.** The Function checks that the encounter has an
  uploaded photo in Storage. That makes probing with crafted vectors costly. Recomputing on the
  server is possible later if abuse appears.
- **Caps per person:** 30 fingerprints a day; at most 6 distinct cells a week (real people meet
  cats in a few cells); at most 3 open suggestions; at most 2 new ones a week.
- **Eligibility:** opting in needs an account signed in with Google, not anonymous (decided 13
  Nov, question 3). Nothing else is required.
- **Consent, and no photos before a chat.** Nothing about the other person is shown until both say
  yes. Photos of the cat, if they are shared at all, are shared inside the chat by the person's
  choice, re-encoded without EXIF.
- **Delayed delivery** (section 4) and silent declines.
- **Report and block** on every suggestion, chat and link: closes the pair, blocks that person-pair
  for ever, and writes to a `reports` collection for a future moderator (access-design).
- No counts or popularity ("3 people know this cat") anywhere, as privacy-and-safety requires.

## 7. Consent and UX

**Opt-in** (Settings, off by default): "Find neighbours who know the same cats" /
"Encontrar vecinos que conocen a los mismos gatos". The explanation: "Your phone makes a
fingerprint of each cat photo and compares it with others nearby. Nobody sees your photos,
name or where you are. If you both say it is the same cat, you can start a private chat with the
other person's nickname, and what you share there is up to you." / "Tu teléfono crea una huella de
cada foto de un gato y la compara con otras cercanas. Nadie ve tus fotos, tu nombre ni dónde estás.
Si ambas personas dicen que es el mismo gato, se puede abrir un chat privado con el apodo de la
otra, y lo que se comparta allí lo decide cada una." Turning it off deletes everything (section 4).

| Step | EN | ES |
|---|---|---|
| card title | Someone nearby may know this cat too | Puede que alguien cerca también conozca a este gato |
| card body | Another person who meets cats around here has photos of a cat that looks like {name}. Nothing about them or you has been shared. Is this the same cat? | Otra persona que conoce gatos por aquí tiene fotos de un gato que se parece a {name}. No se ha compartido nada sobre esa persona ni sobre ti. ¿Es este el mismo gato? |
| buttons | Yes, same cat · No · Not sure | Sí, es el mismo · No · No lo sé |
| chat opened | You can now chat with {nickname}. Only nicknames are shown. | Ya puedes hablar con {nickname}. Solo se muestran los apodos. |
| closed | This suggestion has closed. | Esta sugerencia se cerró. |

"{name}", not "your {name}": nobody owns these cats. **What both-yes gives** (decided 13 Nov): a
private chat between the two nicknames only (or "A neighbour" / "Un vecino" if one has none). No
name for the cat, no photo, no story. From there the people decide everything themselves: talk,
share what they choose, link their records only if both agree (life-events-design, "When records
are linked"), simply keep caring for the cat when it visits, or leave. Either can leave or block
at any time. The app does not coach, mediate or take sides. Situations vary (a stray visiting two
homes, one person's pet visiting another's, two people who each consider it their pet), and people
are who they are. Nothing is merged, and each person keeps their own record and name.

**The chat is a new feature** and needs its own design: moderation, report and block, retention,
and what the app stores. Until that exists, no chat is built.

**Open point:** "Is this the same cat?" needs something to judge against, and this draft shows no
photo of the other side before the chat. David has not decided whether an anonymous crop of the
other cat may be shown at this step. If it is, it is the one exception to "photos only in chat".

## 8. If fingerprints are too weak: the fallback

**"Ask the neighbours"**, started by the person, never automatic. On one of their cats, "Does
anyone nearby know this cat?" sends their chosen cat crop (plus the coat, if set) to opted-in
people whose cats were met in the same 9 cells, using the same delay, caps and yes/no answers,
then the chat. Those people answer "I know this cat" and pick which of their cats it is. The server
still picks the recipients, so the asker never learns who they are, as with the missing-cat alerts
in access-design. Limit it to 1 ask per cat per month. Area + coat alone (no photos compared) is
too weak to push suggestions, but good enough to choose who gets asked. This works for solid
black cats too.

## 9. Evaluation before anyone sees a suggestion

1. **Offline, on David's Mac** (Python, no Firebase): David's cats with several encounters, plus
   the site's own cat photos, labelled by cat. For each model (DINOv2-S, MobileNetV3, with and
   without the crop), compute all encounter pairs. Report: the similarity distributions for same vs
   different cat, precision and recall at each threshold, top-1 among David's cats, and the results
   split by coat. It is small (about 10 cats), so also simulate "other people" by holding out
   encounters. **Go/no-go 1:** precision ≥ 0.9 at recall ≥ 0.3 for non-black coats. If no model
   passes, build section 8 instead.
2. **On the phone (rollout step 2):** each "This might be Ninja? Yes / No" answer is a free label.
   Count locally whether the fingerprint agreed. The count stays on the phone, and David reads
   his own.
3. **Shadow mode (step 4):** the server builds `matchPairs` but delivers nothing. Logs hold only
   numbers (sims, counts per cell, cost per photo). Precision comes from **testers** (David plus
   friends with real accounts, opted in) who judge their own pairs. **Go/no-go 2:** at least 80%
   correct on at least 30 judged pairs, at most 1 suggestion per person a month, and cost per
   photo within 2× of section 5.

## 10. Rollout (each step ships alone)

1. **On-device detector + embedder**, the "real cat" check, fingerprints cached locally. No
   network. Plus the offline evaluation (go/no-go 1). App screenshot per the Conventions.
2. **Matching v2 on the device:** a similarity term in `MatchingService.rank` (best gallery match
   per cat), local agreement counts.
3. **Opt-in + inbox + `matchIndex` filing**, with no queries yet. Needs **Functions on Blaze**
   (Cloud Build, Artifact Registry, Eventarc APIs), the composite vector index
   (`gcloud firestore indexes composite create … --field-config field-path=embedding,
   vector-config='{"dimension":"384","flat":"{}"}'`), a TTL policy on `expireAt`, rules + emulator
   tests (inbox write-only, `matchIndex`/`matchPairs` denied to everyone including admin), and a
   budget alert. Privacy page (both languages, `updated:` dates) *before* this ships.
4. **Shadow matching** with testers (go/no-go 2). Cloud Tasks queue for the delayed delivery.
5. **Suggestions and yes/no answers** for testers, then for everyone opted in. Report and block.
   **Private chat** after its own design is written (moderation, report and block, retention).
6. **Link creation**, once `links` exists (life-events-design steps 7–8). Only by both people's
   agreement, from inside a chat or from their own records.
7. Fallback "ask the neighbours" (section 8), if step 1 or 4 fails, or in addition.

## 11. Questions for David (decided 13 Nov, except 5)

1. **Licence:** decided. Only free models under a permissive licence (Apache-2.0 or MIT).
   Non-commercial models such as MegaDescriptor (CC BY-NC) are excluded, not just outranked. Start
   with DINOv2-small and measure.
2. **Reveal:** decided. A mutual "same cat" reveals nothing. Both yes opens a private chat between
   the two nicknames only, and the people decide the rest (section 7). The chat is a new feature
   with its own design still to write.
3. **Eligibility:** decided. Matching can be switched on only by accounts signed in with Google
   (not anonymous), to make throwaway probing harder. No other requirement.
4. **Coat:** decided. Optional, very broad, never required: hair (short / long) and colour (black,
   white, grey, orange, tabby, calico/tortoiseshell, mixed), each with "Not sure". The matcher uses
   it only to veto obvious mismatches, never to decide.
5. **Shadow review:** still open. David has not decided whether testers' pairs may include photos
   from non-testers who opted in. Until he does, default to tester-to-tester pairs only.

Sources: [1] WildlifeDatasets toolkit, arxiv.org/abs/2311.09118. [2] PetFace, ECCV 2024,
arxiv.org/abs/2407.13555 and dahlian00.github.io/PetFacePage (research-only data).
[3] huggingface.co/BVRA/MegaDescriptor-T-224. [4] huggingface.co/conservationxlabs/miewid-msv3.
[5] firebase.google.com/docs/firestore/vector-search (2048 dims max, cosine/euclidean/dot,
flat index, limit ≤ 1000, pre-filter needs a composite index, no realtime listeners).
[6] firebase.google.com/docs/firestore/pricing (1 read per 100 kNN index entries). Prices and
on-device timings are estimates to re-check before step 3.
