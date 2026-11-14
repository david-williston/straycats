# match-eval: offline test of cat fingerprints

Step 1 of [cross-person-matching-design.md](../../docs/cross-person-matching-design.md): can
DINOv2-small (and MobileNetV3 as a fallback) tell the owner's cats apart? Results: [RESULTS.md](RESULTS.md).

Downloaded photos and results stay **outside the repo** (they are personal data). Nothing here
writes to Firestore or Storage.

```bash
D=/some/scratch/folder            # NOT inside the repo
python3 -m venv $D/venv && $D/venv/bin/pip install -r requirements.txt
gcloud auth application-default login      # once; quota project straycats-love
$D/venv/bin/python fetch.py $D/data        # read-only export: meta.json + photos/
$D/venv/bin/python eval.py $D/data --black Name1,Name2 [--exclude photoId,photoId] --out $D/results.json
```

`fetch.py` reads `users/*/cats` and `users/*/encounters`; the label is "same uid + catId = same cat".
`--black` names cats to report separately; `--exclude` drops photos that are not real cat photos.

Models (permissive licences only): Faster R-CNN MobileNetV3 FPN COCO detector (BSD-3), DINOv2-small
(Apache-2.0), torchvision MobileNetV3-Large ImageNet features (BSD-3). Weights download on first run.
