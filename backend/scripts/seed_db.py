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
    
    print("--- Seeding Re-architected Firestore Data ---")
    batch = db.batch()
    
    # 1. Specialist User
    user_ref = db.collection('users').document('DOC_001')
    batch.set(user_ref, {
        'uid': 'DOC_001',
        'email': 'specialist@hospital.med',
        'full_name': 'Dr. Nguyen Van A',
        'role': 'specialist',
        'created_at': datetime.now(),
        'status': 'active'
    })
    
    # 2. Specialist Doctor Details (Simplified as per Arch update)
    doctor_ref = db.collection('doctors').document('DOC_001')
    batch.set(doctor_ref, {
        'id': 'DOC_001',
        'specialty': 'Di truyền học',
        'department_id': 'DEPT_LAB_01'
    })
    
    # 3. Patients
    p1 = {'id': 'PAT_001', 'full_name': 'Patient Alpha', 'patient_code': 'BN001', 'gender': 'Nam', 'dob': '1990-01-01'}
    p2 = {'id': 'PAT_002', 'full_name': 'Patient Beta', 'patient_code': 'BN002', 'gender': 'Nữ', 'dob': '1995-05-15'}
    batch.set(db.collection('patients').document(p1['id']), p1)
    batch.set(db.collection('patients').document(p2['id']), p2)
    
    # 4. Appointment (Denormalized)
    app_ref = db.collection('appointments').document('APP_001')
    batch.set(app_ref, {
        'id': 'APP_001',
        'patient_id': db.document('patients/PAT_001'),
        'patient_name': 'Patient Alpha',
        'doctor_id': db.document('doctors/DOC_001'),
        'doctor_name': 'Dr. Nguyen Van A',
        'appointment_date': datetime.now(),
        'status': 'scheduled',
        'reason': 'Khám di truyền tiền hôn nhân'
    })
    
    # 5. Test Order (Denormalized)
    order_ref = db.collection('test_orders').document('ORDER_001')
    batch.set(order_ref, {
        'id': 'ORDER_001',
        'patient_id': db.document('patients/PAT_001'),
        'patient_name': 'Patient Alpha',
        'patient_code': 'BN001',
        'appointment_id': db.document('appointments/APP_001'),
        'specialist_id': db.document('doctors/DOC_001'),
        'status': 'CULTURING', # Updated to culturing
        'iscn_formula': '46,XY',
        'diagnosis_conclusion': 'Chưa có kết quả',
        'created_at': datetime.now(),
        'updated_at': datetime.now()
    })
    
    # 6. Sample (with is_current logic)
    sample_ref = db.collection('samples').document('SMP_001')
    batch.set(sample_ref, {
        'id': 'SMP_001',
        'test_order_id': db.document('test_orders/ORDER_001'),
        'patient_id': db.document('patients/PAT_001'),
        'is_current': True,
        'sample_type': 'PERIPHERAL_BLOOD',
        'status': 'CULTURING',
        'collection_time': datetime.now(),
        'created_at': datetime.now(),
        'updated_at': datetime.now()
    })
    
    # Commit root collections
    batch.commit()
    print("Seeded Root Collections (Users, Doctors, Patients, Appts, Orders, Samples)")
    
    # 7. Metaphase Image (Sub-collection)
    img_ref = db.collection('test_orders/ORDER_001/metaphase_images').document('IMG_001')
    img_ref.set({
        'id': 'IMG_001',
        'raw_image_url': 'https://firebasestorage.googleapis.com/.../test_metaphase.jpg',
        'ai_count': 46,
        'processing_time': 1.25, # seconds
        'is_selected': True
    })
    print("Seeded Metaphase Image sub-collection")
    
    # 8. Chromosome (Sub-collection)
    chrom_ref = db.collection('test_orders/ORDER_001/metaphase_images/IMG_001/chromosomes').document('CH_01')
    chrom_ref.set({
        'id': 'CH_01',
        'label': '1',
        'coordinates': {'x': 100, 'y': 200, 'w': 30, 'h': 60},
        'mask_url': 'https://firebasestorage.googleapis.com/.../mask_ch1.png',
        'rotation': 45.0,
        'is_flipped': False
    })
    print("Seeded Chromosome sub-collection")
    
    print("--- Seeding Complete ---")

if __name__ == "__main__":
    seed()
