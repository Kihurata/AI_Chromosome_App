import os
import sys
from datetime import datetime

# Add the parent directory to sys.path to import from 'app'
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import firebase_admin
from firebase_admin import credentials, firestore

def seed():
    # Service account key is at root of backend (up one level from here)
    key_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
    
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    
    print("--- Seeding Firestore Data ---")
    
    # 1. Specialist User
    user_ref = db.collection('users').document('DOC_001')
    user_ref.set({
        'uid': 'DOC_001',
        'email': 'specialist@hospital.med',
        'full_name': 'Dr. Nguyen Van A',
        'role': 'specialist',
        'created_at': datetime.now(),
        'status': 'active'
    })
    print("Created mock specialist user: DOC_001")
    
    # 2. Specialist Doctor Details
    doctor_ref = db.collection('doctors').document('DOC_001')
    doctor_ref.set({
        'id': 'DOC_001',
        'specialty': 'Di truyền học',
        'department_id': 'DEPT_LAB_01',
        'biography': 'Chuyên gia phân tích nhiễm sắc thể với 10 năm kinh nghiệm.',
        'rating': 4.9
    })
    print("Created mock doctor details: DOC_001")
    
    # 3. Patients
    patients = [
        {'id': 'PAT_001', 'full_name': 'Patient Alpha', 'patient_code': 'BN001', 'gender': 'Nam', 'dob': '1990-01-01'},
        {'id': 'PAT_002', 'full_name': 'Patient Beta', 'patient_code': 'BN002', 'gender': 'Nữ', 'dob': '1995-05-15'}
    ]
    for p in patients:
        db.collection('patients').document(p['id']).set(p)
        print(f"Created patient: {p['id']} ({p['full_name']})")
        
    # 4. Test Order
    order_ref = db.collection('test_orders').document('ORDER_001')
    order_ref.set({
        'id': 'ORDER_001',
        'patient_id': db.document('patients/PAT_001'),
        'specialist_id': db.document('doctors/DOC_001'),
        'status': 'PENDING',
        'iscn_formula': '46,XY',
        'diagnosis_conclusion': 'Chưa có kết quả',
        'created_at': datetime.now(),
        'updated_at': datetime.now()
    })
    print("Created test order: ORDER_001")
    
    print("--- Seeding Complete ---")

if __name__ == "__main__":
    seed()
