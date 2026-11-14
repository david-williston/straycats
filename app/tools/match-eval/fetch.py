"""Read-only export of cats, encounters and photos for the offline evaluation.

Reads Firestore users/{uid}/cats and users/{uid}/encounters, downloads
users/{uid}/photos/{photoId}.jpg from Storage into DATA_DIR (outside the repo).
Never writes to Firestore or Storage. Uses Application Default Credentials.
"""
import json, os, sys
import firebase_admin
from firebase_admin import firestore, storage

PROJECT = "straycats-love"
BUCKET = "straycats-love.firebasestorage.app"
data_dir = sys.argv[1]
os.makedirs(os.path.join(data_dir, "photos"), exist_ok=True)

firebase_admin.initialize_app(options={"projectId": PROJECT, "storageBucket": BUCKET})
db = firestore.client()
bucket = storage.bucket()

rows, cats = [], {}
uids = {}
for u in db.collection("users").list_documents():
    short = uids.setdefault(u.id, f"u{len(uids)}")
    for c in u.collection("cats").stream():
        d = c.to_dict()
        cats[f"{short}/{c.id}"] = {"name": d.get("name"), "color": d.get("color") or d.get("coat")}
    for e in u.collection("encounters").stream():
        d = e.to_dict()
        if not d.get("catId") or not d.get("photoId"):
            continue
        rows.append({"uid": short, "realUid": u.id, "cat": f"{short}/{d['catId']}",
                     "photoId": d["photoId"], "enc": e.id})
print("users", len(uids), "cats", len(cats), "encounters with photo", len(rows))
for r in rows:
    path = os.path.join(data_dir, "photos", f"{r['uid']}_{r['photoId']}.jpg")
    r["file"] = path
    if not os.path.exists(path):
        blob = bucket.blob(f"users/{r['realUid']}/photos/{r['photoId']}.jpg")
        try:
            blob.download_to_filename(path)
        except Exception as ex:
            r["file"] = None
            print("missing photo", r["uid"], type(ex).__name__)
    r.pop("realUid")
rows = [r for r in rows if r["file"]]
json.dump({"cats": cats, "encounters": rows}, open(os.path.join(data_dir, "meta.json"), "w"), indent=1)
print("downloaded", len(rows))
