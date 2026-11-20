---
title: "The Paper Collar: a First Specification"
date: 2026-11-20
weight: 521
tags: ["lost-and-found", "safety", "community"]
summary: "SC-PC-001 Rev A, a draft manufacturing specification for a ready-made paper collar: four sizes, a weak link that releases first, a one-way ratchet and an NFC tag that holds only an ID. Drafted with AI to get people talking, and probably wrong in many ways."
question: "Would a ready-made collar like this be worth making, and what would you want to see tested first?"
updated: 2026-11-20
cover:
  image: "collar-render.jpg"
  alt: "A render of a ring-shaped paper cat collar with a cream side printed with orange and grey cats, pink flowers and green and yellow leaves, and a teal inside with cream paw prints. A small cream NFC pod with a signal symbol sits on the front, a white ratchet buckle is at the right, a row of small perforations is on the left, and water droplets sit on the paper"
  caption: "Concept render, not a real product."
---

People who meet a stray cat sometimes put a [paper collar](/ideas/paper-collar/) on it, with
their phone number, so the owner or the next person who meets the cat can get in touch. I want
to take that further: one open, worldwide specification for cat collars that anyone can make, from a cheap
disposable strip for a stray to a durable collar for your own cat, so anyone can identify a cat
that is lost, injured or has died.

This first draft was written with AI and is probably wrong in many ways. That's on purpose: it's
here to get people talking. If you know paper, NFC tags, collars or cats, tell me what's wrong.

You can read it below, or listen first.

## Listen to the debate

Two AI-generated voices argue about the details of this specification, taking opposite sides.
I made it with Google's NotebookLM from this page. Like the spec itself, it may get things
wrong, but it's a good way into the questions.

{{< listen src="debate-en.m4a" title="*Standardizing Smart Breakaway Cat Collars*, an AI-generated debate about the details of this specification (about 19 minutes)" >}}

## The specification

**SC-PC-001 Rev A, draft, 20 Nov 2026.** This is a draft idea, not a product. All figures and
numbers are design targets or assumptions to be tested, unless marked as sourced. Nothing has
been built or tested.

*A newton (N) is a unit of force. One newton is roughly the weight of 100 g, so 10 N is about the weight of a 1 kg bag of sugar.*

Related ideas:
[The Paper Collar](/ideas/paper-collar/),
[What If Every Cat Could Carry an Open Identity?](/ideas/open-cat-identity/),
[When a Cat Goes Missing](/ideas/when-a-cat-goes-missing/),
[Stray, Pet, or Somewhere in Between?](/ideas/lost-and-found/),
[Make Help Easier to Find Than Dumping](/ideas/help-easier-than-dumping/) and
[Privacy & Animal Safety](/ideas/privacy-and-safety/).

## 1. Purpose

A cheap, attractive, reversible, water-resistant paper collar that fits kittens through large
cats. It must break away safely, survive normal wear, and carry an NFC tag that holds an
identifier only. This follows the [open identity idea](/ideas/open-cat-identity/): the collar
carries an ID, not personal data.

## 2. Requirements

| # | Requirement | Target |
|---|---|---|
| R1 | Breakaway | Releases at a defined tensile load per size (section 5) |
| R2 | Durability | 30 days nominal outdoor wear (design target) |
| R3 | Identification | NFC tag (NTAG213) plus printed short URL and QR code |
| R4 | Water resistance | Survives rain and grooming, retains at least 50% of dry strength after 24 h immersion (target) |
| R5 | Comfort | Strap 8 to 14 mm wide, 0.24 mm thick away from the pod |
| R6 | Closure | One-way ratchet, no tape, no adhesive against fur |
| R7 | Reversible | Pattern on side A, ID side B, both finished |
| R8 | Cost | Target US$0.50 or less per unit at volume, tag included |
| R9 | Fit | Four sizes, kitten to large, 12 to 32 cm neck |

## 3. Sizes

{{< photo src="fig1-plan-view.svg" alt="Plan view of the paper collar, size M. A horizontal strip 335 mm long with a ratchet head (slot and pawl) at the left, a calibrated perforation weak link, an NFC pod holding a 12 by 19 mm inlay, and a tooth field with 3 mm pitch and a tapered tail at the right. Labelled dimensions are 24 mm for the head, 12 mm for the strap width, 26 mm for the pod and 50 mm for the tooth field." caption="Fig. 1: Plan view, size M, drawn to scale. All dimensions in mm. Concept drawing, not a real product." >}}

Closed circumference is neck plus 20 mm for kittens and neck plus 30 mm for adults, so a finger
fits under it. The ratchet adjusts over a 60 mm range. Strap length is the 24 mm head, plus the
maximum circumference, plus a 10 mm trim allowance. Neck ranges follow commercial cat collar size
charts (see Sources).

| Size | Neck (cm) | Closed circ. (cm) | Strap width | Strap length |
|---|---|---|---|---|
| K kitten | 12 to 18 | 14 to 20 | 8 mm | 235 mm |
| S small | 16 to 22 | 19 to 25 | 10 mm | 285 mm |
| M medium | 21 to 27 | 24 to 30 | 12 mm | 335 mm |
| L large | 26 to 32 | 29 to 35 | 14 mm | 385 mm |

The NFC pod is 14 mm wide by 26 mm long on every size. On K, S and M the strap widens locally at
the pod.

## 4. Materials (baseline)

- Face paper: 90 to 100 gsm wood-free paper, about 100 µm per ply, grain running along the strap.
- Barrier: water-based coating on both outer faces, about 10 µm each.
- Core: edge adhesive rails, about 20 µm, plus the NFC inlay.
- Inks: water-based, non-toxic, no metallic or heavy-metal pigments.
- Alternative to test: coated synthetic (film-based) paper. The [paper collar article](/ideas/paper-collar/) rules out Tyvek because it is built to resist tearing.

{{< photo src="exploded-layers.jpg" alt="An exploded render of a reversible paper cat collar. Small closed rings on the left show the patterned side and the plain side. On the right, from top to bottom: a printed patterned paper strip with a blue cat and leaves, a clear water-resistant layer, an NFC inlay with a gold antenna floating above a shallow tray, a plain base paper strip with ratchet teeth, a slot and perforations, and two thin edge strips. Four close-ups at the bottom show the laminated layers, the inlay and tray, the teeth and slot, and the perforated tail" caption="Concept render of the layers, not a real product. It shows the idea, not the exact materials or thicknesses in this specification." >}}

{{< photo src="fig2-pod-section.svg" alt="Section through the NFC pod. Five layers from top to bottom: a water-barrier coat of about 10 µm, printed face paper A of about 100 µm, a core layer of about 160 µm holding the adhesive rails and a floating NFC inlay, printed face paper B of about 100 µm, and a second water-barrier coat of about 10 µm. Two 2 mm gaps mark the clearance between the inlay and the adhesive rails." caption="Fig. 2: Section through the NFC pod. Thickness exaggerated. Inlay is not bonded inside the clearance. Concept drawing, not a real product." >}}

Thickness: about 0.24 mm along the strap and about 0.38 mm at the pod. Corners are radiused at
R1.5 mm or more.

## 5. Mechanics and physics

**Failure hierarchy.** The weak link must fail first, then the ratchet, then the strap body.

{{< photo src="fig3-force-targets.svg" alt="Release force targets by collar size. For kitten, small, medium and large, a release window in newtons (nominal, plus or minus 25%) sits well below the ratchet hold force and far below the cat's body weight. A reference line at 20 N marks a typical retail breakaway buckle (4.5 lb)." caption="Fig. 3: Release windows, ratchet hold and cat body weight by size. Design targets, not measured values." >}}

| Size | Release (nominal) | Ratchet holds at least | Strap body at least | Cat weight | Release as % of weight |
|---|---|---|---|---|---|
| K | 6 N (1.3 lb) | 9 N | 12 N | 1 kg = 9.8 N | 61% |
| S | 10 N (2.2 lb) | 15 N | 20 N | 3 kg = 29 N | 34% |
| M | 15 N (3.4 lb) | 22 N | 30 N | 5 kg = 49 N | 31% |
| L | 20 N (4.5 lb) | 30 N | 40 N | 7 kg = 69 N | 29% |

Release tolerance is ±25%. For comparison, a common retail breakaway buckle releases at about
4.5 lb (20 N), and sources quote roughly 2 to 5 lb overall.

**Weak link sizing.** Strap tension is the same everywhere along the strap, so the narrowest
cross-section sets the break load. Net width = release force ÷ paper tensile strength per mm.
Assumption: 4 N per mm of width for 90 to 100 gsm paper along the grain. This must be measured.

| Size | Release | Net width at weak link | Share of strap width |
|---|---|---|---|
| K | 6 N | 1.5 mm | 19% |
| S | 10 N | 2.5 mm | 25% |
| M | 15 N | 3.75 mm | 31% |
| L | 20 N | 5.0 mm | 36% |

A plain 12 mm strip would carry roughly 48 N at that strength, about three times the M target.
So the strap needs a designed weak link: a 12 mm zone of perforation bridges. Final geometry
comes from pull testing.

**Ratchet.** A die-cut tooth field on the tail (3 mm pitch, 50 mm long) engages a slot and pawl
in the head, like a zip tie. It is one-way and cannot be loosened once closed, so the strap is
cut with scissors to remove it.

**Hanging case.** If a cat hangs by the collar, the load equals its body weight. Release at 29 to
34% of weight for S, M and L means the collar opens well before the load gets dangerous.

## 6. NFC

- Chip: NXP NTAG213, 144 bytes user memory, ISO 14443A, 13.56 MHz.
- Smallest practical inlay: antenna 10 x 17 mm, die-cut about 12 x 19 mm, 157 µm thick, PET-faced and waterproof to rain and spray (sourced). A round inlay is much bigger (16 mm antenna at the smallest), so a rectangular one fits a narrow strap.
- Payload: a short NDEF URL, for example straycats.love/c/ plus an 8-character ID. This fits comfortably in 144 bytes. Lock the tag after writing.
- Printed fallback on side B: short URL and a QR code at least 12 x 12 mm, so phones without NFC still work.

**Inlay load limit.** The inlay datasheet states bending diameter above 50 mm and tension under
10 N. The M and L release forces (15 and 20 N) exceed 10 N, so the inlay must carry no strap
load. That is why Fig. 2 has a floating pocket: the inlay is not bonded within 2 mm of the
adhesive rails, so the paper plies carry the load around it.

## 7. Printing and design

- Side A: pattern library with many designs for all ages and cultures. Side B: ID side with QR, short URL and a blank for a contact line.
- Sheets are die-cut and perforated, sold as packs with several replacements, since cats lose collars.

## 8. Safety rules

- Only for friendly, handleable cats.
- Fit: about two fingers (one for kittens) under the collar.
- Trim the tail to 10 mm or less after fitting.
- Check the fit and the cat's neck regularly. Kitten necks grow, so refit kittens often.
- Remove at once if the cat scratches at it or the paper is wet and swollen.

## 9. Test plan

| Test | Method | Pass |
|---|---|---|
| Strap tensile | ISO 1924-2 on coupons, then pull test on finished collars at 100 mm/min | Release within ±25% of target |
| Ratchet hold | Pull test on closed collars | At least the table value |
| Water | Cobb test (ISO 535), 24 h immersion, then wet tensile | At least 50% strength retained |
| NFC | Read test dry, wet, flexed, after 30 days | 100% read on common phones |
| Wear | Fit trial on live cats under supervision | No skin irritation, no failed releases |

## 10. Open items

1. **Kitten size vs. inlay bend limit.** A 12 cm neck is a 38 mm diameter, below the inlay's 50 mm bending minimum. Options: keep the pod as a flat plate, use a smaller 8.7 mm inlay (a listing exists, performance unverified), or leave the smallest kitten size without NFC.
2. **Kittens under 1 kg.** A 6 N release is 61% of a 1 kg kitten's weight. Lighter kittens probably need about 4 N, to be confirmed by test.
3. **Conflict with the paper collar article**, which says "not for kittens" and "loose is safer." This spec includes kittens and a firm ratchet fit. The article should change, or the spec should.
4. **Paper strength is assumed.** Measure it before freezing the weak link.
5. **QR size and NFC read range** on a 14 mm pod need real phone tests.
6. **Cost.** The NFC inlay alone lists at about €0.19 to €0.23 each in volume (NTAG213, 12 x 19 mm), so the US$0.50 target is tight and needs supplier quotes.

## Sources

- [LupinePet breakaway cat collar, ~4.5 lb release](https://www.chewy.com/lupinapet-microbatch-limited-edition/dp/3678726)
- [Outdoor Bengal on breakaway forces](https://www.outdoorbengal.com/blogs/adventure-cat-training/breakaway-collars)
- [Cheshire & Wain cat collar size chart](https://www.cheshireandwain.com/en-nz/products/custom-personalisation-charge)
- [Catlog size guide](https://rabo.cat/en-us/catlog/pendant/belt-size)
- [Avery Dennison Circus Mini inlay (16 mm antenna)](https://rfid.averydennison.com/en/home/product-finder/circus-mini.html)
- [Avery Dennison Midas NFC inlay (10 x 17 mm antenna)](https://rfid.averydennison.com/en/home/product-finder/midas-nfc.html)
- [NFC wet inlay NTAG213 12 x 19 mm, thickness, bend limits and price](https://shopnfc.com/en/nfc-stickers/32-12mm-micro-ntag213-stickers.html)
- [Tyvek properties](https://www.dupont.com/what-is-tyvek.html)
