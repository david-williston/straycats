"""Offline evaluation of cat fingerprints (cross-person-matching-design.md, step 1).

usage: python eval.py DATA_DIR [--black Name1,Name2] [--out results.json]
DATA_DIR holds meta.json + photos/ written by fetch.py (kept outside the repo).

Models (permissive licences only):
  detector  torchvision Faster R-CNN MobileNetV3-Large FPN, COCO 'cat' (BSD-3)
  dino      facebook/dinov2-small CLS token, 384-d (Apache-2.0)
  mnv3      torchvision MobileNetV3-Large ImageNet pooled features, 960-d (BSD-3)
Each embedder is run on the detector crop (+10% margin) and on the whole photo.
"""
import json, os, sys, time, argparse
import numpy as np, torch
from PIL import Image, ImageOps
import torchvision
from torchvision.models import detection
from transformers import AutoImageProcessor, AutoModel

ap = argparse.ArgumentParser()
ap.add_argument("data"); ap.add_argument("--black", default="Ciccio,Chicco")
ap.add_argument("--out", default=None)
ap.add_argument("--exclude", default="", help="comma-separated photoIds to drop (e.g. photos of a screen, test shots)")
a = ap.parse_args()
meta = json.load(open(os.path.join(a.data, "meta.json")))
cats = meta["cats"]
skip = set(x for x in a.exclude.split(",") if x)
encs = [e for e in meta["encounters"] if e["photoId"] not in skip]
black = {n.strip() for n in a.black.split(",")}
dev = "cpu"  # keep timing comparable and simple
torch.set_grad_enabled(False)

imgs = [ImageOps.exif_transpose(Image.open(e["file"])).convert("RGB") for e in encs]

# ---- detector ----
det = detection.fasterrcnn_mobilenet_v3_large_fpn(weights="DEFAULT").eval()
CAT = 17
crops, found, t_det = [], [], []
for im in imgs:
    t = time.time()
    x = torchvision.transforms.functional.to_tensor(im)
    out = det([x])[0]
    t_det.append(time.time() - t)
    best = None
    for b, l, s in zip(out["boxes"], out["labels"], out["scores"]):
        if int(l) == CAT and float(s) >= 0.3:
            area = float((b[2] - b[0]) * (b[3] - b[1]))
            if best is None or area > best[0]:
                best = (area, b)
    if best is None:
        crops.append(im); found.append(False); continue
    x0, y0, x1, y1 = [float(v) for v in best[1]]
    mw, mh = 0.1 * (x1 - x0), 0.1 * (y1 - y0)
    box = (max(0, x0 - mw), max(0, y0 - mh), min(im.width, x1 + mw), min(im.height, y1 + mh))
    crops.append(im.crop(tuple(int(v) for v in box))); found.append(True)
print(f"detector found a cat in {sum(found)}/{len(found)} photos")

# ---- embedders ----
proc = AutoImageProcessor.from_pretrained("facebook/dinov2-small")
dino = AutoModel.from_pretrained("facebook/dinov2-small").eval()
mn = torchvision.models.mobilenet_v3_large(weights="DEFAULT").eval()
mn_tf = torchvision.transforms.Compose([
    torchvision.transforms.Resize((224, 224)), torchvision.transforms.ToTensor(),
    torchvision.transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])])

def f_dino(im):
    v = dino(**proc(images=im, return_tensors="pt")).last_hidden_state[:, 0][0]
    return v.numpy()
def f_mn(im):
    f = mn.avgpool(mn.features(mn_tf(im)[None])).flatten(1)[0]
    return f.numpy()

def embed(fn, ims):
    ts, vs = [], []
    for im in ims:
        t = time.time(); v = fn(im); ts.append(time.time() - t)
        vs.append(v / np.linalg.norm(v))
    return np.stack(vs), float(np.mean(ts))

E, timing = {}, {"detect_s": float(np.mean(t_det))}
for mname, fn in [("dino", f_dino), ("mnv3", f_mn)]:
    for inp, ims in [("crop", crops), ("whole", imgs)]:
        E[f"{mname}-{inp}"], timing[f"{mname}-{inp}_s"] = embed(fn, ims)

# ---- metrics ----
cat_of = np.array([e["cat"] for e in encs])
names = {c: cats.get(c, {}).get("name") for c in set(cat_of)}
counts = {c: int((cat_of == c).sum()) for c in set(cat_of)}
n = len(encs)
multi = [i for i in range(n) if counts[cat_of[i]] >= 2]
is_black = np.array([names[c] in black for c in cat_of])
pos_pairs = sum(counts[c] * (counts[c] - 1) // 2 for c in counts)
print(f"{n} photos, {len(counts)} cats, {len(multi)} photos of cats with >=2 photos, {pos_pairs} positive pairs")

def pr_points(scores, correct, has_pos):
    """scores/correct per query (top-1 cat); recall denominator = queries that have a true match."""
    order = np.argsort(-scores); pts = []
    for T in sorted(set(np.round(scores, 4)), reverse=True):
        sel = scores >= T - 1e-9
        tp = int((correct & sel).sum()); k = int(sel.sum())
        pts.append((float(T), tp / k if k else 0.0, tp / max(1, int(has_pos.sum())), k))
    return pts

results = {}
for key, V in E.items():
    S = V @ V.T; np.fill_diagonal(S, -9)
    top1 = top3 = 0
    for i in multi:
        order = np.argsort(-S[i]); order = order[order != i]
        top1 += cat_of[order[0]] == cat_of[i]
        top3 += any(cat_of[j] == cat_of[i] for j in order[:3])
    # gallery-per-cat: best similarity to any other photo of each other cat
    sc, ok, hp, blk = [], [], [], []
    for i in range(n):
        best = {}
        for j in range(n):
            if j != i: best[cat_of[j]] = max(best.get(cat_of[j], -9), S[i, j])
        c, s = max(best.items(), key=lambda kv: kv[1])
        sc.append(s); ok.append(c == cat_of[i]); hp.append(counts[cat_of[i]] >= 2); blk.append(is_black[i])
    sc, ok, hp, blk = map(np.array, (sc, ok, hp, blk))
    def best_point(mask):
        pts = pr_points(sc[mask], ok[mask], hp[mask]) if mask.any() else []
        good = [p for p in pts if p[1] >= 0.9 and p[2] >= 0.3]
        bestp = max(pts, key=lambda p: (p[1] >= 0.9, p[2])) if pts else None
        return {"passes_bar": bool(good), "best_point(thr,prec,rec,n_suggested)": bestp,
                "max_recall_at_prec>=0.9": max([p[2] for p in pts if p[1] >= 0.9], default=0.0)}
    same = [S[i, j] for i in range(n) for j in range(i + 1, n) if cat_of[i] == cat_of[j]]
    diff = [S[i, j] for i in range(n) for j in range(i + 1, n) if cat_of[i] != cat_of[j]]
    results[key] = {
        "top1": f"{top1}/{len(multi)}", "top3": f"{top3}/{len(multi)}",
        "sim_same_mean": float(np.mean(same)), "sim_diff_mean": float(np.mean(diff)),
        "sim_diff_max": float(np.max(diff)), "sim_same_min": float(np.min(same)),
        "all": best_point(np.ones(n, bool)),
        "non_black": best_point(~blk), "black": best_point(blk),
        "per_cat_top1": {f"{names[c]}": f"{sum(ok[(cat_of == c)])}/{counts[c]}" for c in counts if counts[c] >= 2},
    }
for k, v in results.items(): print(k, json.dumps(v, indent=1))
bl = [i for i in range(n) if is_black[i] or names[cat_of[i]] in ("Chichoo",)]
if len(bl) > 1:
    V = E["dino-crop"]; print("dino-crop sims between black-cat photos (cross-account, not used as labels):",
        [(i, j, round(float(V[i] @ V[j]), 2)) for i in bl for j in bl if i < j])
print("timing (s/photo, CPU)", json.dumps(timing))
if a.out:
    json.dump({"n_photos": n, "n_cats": len(counts), "positive_pairs": pos_pairs,
               "detector_found": sum(found), "timing": timing, "results": results}, open(a.out, "w"), indent=1)
