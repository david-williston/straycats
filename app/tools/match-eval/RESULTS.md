# Offline evaluation results (13 Nov 2026)

Step 1 of the cross-person matching design. **Verdict: inconclusive, leaning "no evidence against".
The dataset is too small and too contaminated to pass or fail the bar.**

## Dataset (honest)
- 18 encounter photos, 9 cats (7 accounts, all the owner's). 13 photos belong to cats with at least
  2 photos, giving 20 positive pairs. Only 4 cats have 2+ photos.
- **Most of it is not real cat photos.** Looking at the images: 2 are a black frame and a box
  ("Test cat"), and about 7 are phone photos of a laptop screen showing the website's cat photos
  (Ninja, Ciccio, Saibo, Meow Meow, Tres). The only genuine multi-photo cat is Lucia (calico, 6
  photos, mostly the same blue bed). So "same cat" success on screen photos is mostly "same screen".
- A clean subset (those 9 removed) has 9 photos, 4 cats, 15 positive pairs, all from Lucia.
- Cross-account black cats (Chichoo, Chicco, probably the same cat, same orange blanket) were
  kept as distinct cats per the brief; their dino-crop similarity is 0.54, above the 0.2 average
  for different cats, so a true match would plausibly be found.

## Setup
Detector: torchvision Faster R-CNN MobileNetV3-Large FPN (BSD-3), COCO cat, score at least 0.3, largest
box plus 10% margin. Embedders: DINOv2-small CLS 384-d (Apache-2.0); torchvision MobileNetV3-Large
ImageNet pooled 960-d (BSD-3). L2-normalised, cosine. Gallery-per-cat score = best similarity to a
cat's other photos; query's top cat suggested if score at least the threshold. Recall counts only
queries whose cat has another photo; singleton photos count as queries too (any suggestion is wrong).
Detector found a cat in 15/18 photos (9/9 on the clean subset).

## Numbers (all 18 photos; top-1/top-3 over the 13 photos of multi-photo cats)
| Model | Top-1 | Top-3 | Best point with precision >= 0.9 (precision, recall) | Passes bar |
|---|---|---|---|---|
| DINOv2-S, crop | 11/13 | 12/13 | 0.91, 0.77 | yes |
| DINOv2-S, whole photo | 12/13 | 13/13 | 0.90, 0.69 | yes |
| MobileNetV3, crop | 10/13 | 11/13 | 0.91, 0.77 | yes |
| MobileNetV3, whole photo | 6/13 | 9/13 | 1.0, 0.15 | no |

Same-cat mean similarity vs different-cat mean (DINOv2 crop): 0.55 vs 0.20 (max different 0.67).
Clean subset (Lucia only positives): all four variants top-1 6/6; DINOv2 crop reaches precision 1.0
at recall 0.83, but with one set of positives this says little. Black cats: only Ciccio had a
partner photo (a screen photo), so the black split is not meaningful. Non-black pass numbers
(precision 1.0, recall 0.36 to 0.55) are driven by screen photos.

## Findings
- Cropping helps MobileNetV3 a lot (6/13 to 10/13), and is neutral for DINOv2 here (whole photo
  also wins on screen photos because the screen is a shared background, a shortcut the crop removes).
- DINOv2-S is at least as good as MobileNetV3 and has the cleaner separation margin.
- "Test cat" photos failed everywhere (not cats).
- Timing on this Mac (CPU, per photo): detector 0.36 s, DINOv2-S 0.044 s, MobileNetV3 0.16 s
  (a desktop proxy only).

## Verdict against the bar (precision >= 0.9 at recall >= 0.3, non-black)
Numerically passed by DINOv2 crop and MobileNetV3 crop, but not credible: one real multi-photo cat,
photographed in one session. It does not rule the approach out, and it does not prove it.

## Recommendations
- Collect a real test set before relying on it: 15 to 20 cats, 4+ photos each, different days, light
  and poses, including black, orange and grey cats and littermates. Photos of other screens do not count.
- Re-run with `eval.py` and keep DINOv2-S with crop as the primary; keep MobileNetV3 + crop as fallback.
- Use the pairwise same/different similarity gap on that set to set thresholds, per coat.
