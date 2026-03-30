import os
import sys
from datetime import datetime

# Add the parent directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import firebase_admin
from firebase_admin import credentials, firestore

ICD_CODES = [
    {"code": "I10", "name": "Essential (primary) hypertension"},
    {"code": "E78.5", "name": "Hyperlipidemia, unspecified"},
    {"code": "Z00.00", "name": "Encounter for general adult medical examination without abnormal findings"},
    {"code": "E11.9", "name": "Type 2 diabetes mellitus without complications"},
    {"code": "J06.9", "name": "Acute upper respiratory infection, unspecified"},
    {"code": "N39.0", "name": "Urinary tract infection, site not specified"},
    {"code": "M54.50", "name": "Low back pain, unspecified"},
    {"code": "J20.9", "name": "Acute bronchitis, unspecified"},
    {"code": "E03.9", "name": "Hypothyroidism, unspecified"},
    {"code": "K21.9", "name": "Gastro-esophageal reflux disease without esophagitis"},
    {"code": "E55.9", "name": "Vitamin D deficiency, unspecified"},
    {"code": "R05.9", "name": "Cough, unspecified"},
    {"code": "J02.9", "name": "Acute pharyngitis, unspecified"},
    {"code": "F41.9", "name": "Anxiety disorder, unspecified"},
    {"code": "F32.9", "name": "Major depressive disorder, single episode, unspecified"},
    {"code": "R53.83", "name": "Other fatigue"},
    {"code": "R10.9", "name": "Unspecified abdominal pain"},
    {"code": "R07.9", "name": "Chest pain, unspecified"},
    {"code": "Z23", "name": "Encounter for immunization"},
    {"code": "J18.9", "name": "Pneumonia, unspecified organism"}
]

def seed_icd():
    key_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
    
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    
    print("--- Seeding 20 Common ICD-10 Codes ---")
    batch = db.batch()
    
    for item in ICD_CODES:
        doc_ref = db.collection('icd_codes').document(item['code'])
        batch.set(doc_ref, {
            'code': item['code'],
            'name': item['name'],
            'searchable_text': f"{item['code'].lower()} {item['name'].lower()}",
            'created_at': datetime.now()
        })
        
    # Commit
    batch.commit()
    print("--- Seeding Complete ---")

if __name__ == "__main__":
    seed_icd()
