import os
import sys
import firebase_admin
from firebase_admin import credentials, firestore

# Set Firebase Key Path
os.environ["FIREBASE_KEY_PATH"] = "backend/serviceAccountKey.json"
key_path = os.environ["FIREBASE_KEY_PATH"]

if not firebase_admin._apps:
    cred = credentials.Certificate(key_path)
    firebase_admin.initialize_app(cred)

db = firestore.client()
docs = db.collection('system_configs').stream()
print("Listing system_configs docs:")
for d in docs:
    print(f"- {d.id}: {d.to_dict()}")

doc = db.collection('system_configs').document('ai_server').get()

if doc.exists:
    print(f"Doc found! Data: {doc.to_dict()}")
else:
    print("Doc NOT found!")
