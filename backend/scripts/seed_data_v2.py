import os
import sys
from datetime import datetime

# Add the parent directory to sys.path to import from 'app'
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import firebase_admin
from firebase_admin import credentials, firestore

def seed():
    key_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
    
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    print("--- Seeding V2 Data (APP_002, ORDER_002, SMP_002) ---")
    batch = db.batch()

    # 1. New Appointment (APP_002 for PAT_002)
    app_ref = db.collection('appointments').document('APP_002')
    batch.set(app_ref, {
        'id': 'APP_002',
        'patient_id': db.document('patients/PAT_002'),
        'patient_name': 'Patient Beta',
        'doctor_id': db.document('doctors/DOC_001'),
        'doctor_name': 'Dr. Nguyen Van A',
        'appointment_date': datetime.now(),
        'status': 'scheduled',
        'reason': 'Kiểm tra nhiễm sắc thể định kỳ'
    })

    # 2. New Test Order (ORDER_002)
    order_ref = db.collection('test_orders').document('ORDER_002')
    batch.set(order_ref, {
        'id': 'ORDER_002',
        'patient_id': db.document('patients/PAT_002'),
        'patient_name': 'Patient Beta',
        'patient_code': 'BN002',
        'appointment_id': db.document('appointments/APP_002'),
        'specialist_id': db.document('users/SuyvcITqmXd0pXYMbhR9a6l1cR52'),
        'status': 'CULTURING', # Trạng thái đang nuôi cấy
        'test_type': 'Karyotyping',
        'priority': 'High',
        'created_at': datetime.now(),
        'updated_at': datetime.now()
    })

    # 3. New Sample (SMP_002)
    sample_ref = db.collection('samples').document('SMP_002')
    batch.set(sample_ref, {
        'id': 'SMP_002',
        'order_id': 'ORDER_002',
        'type': 'Blood',
        'collected_at': datetime.now(),
        'collected_by': 'Ms. Receptionist B',
        'status': 'active',
        'metadata': {'volume': '5ml', 'container': 'Heparin Tube'}
    })

    # 4. Add a sample image for ORDER_002
    img_ref = db.collection('test_orders/ORDER_002/metaphase_images').document('IMG_002')
    batch.set(img_ref, {
        'id': 'IMG_002',
        'raw_image_url': 'https://firebasestorage.googleapis.com/v0/b/ai-chromosome-app.appspot.com/o/samples%2Fsample_chromosome.jpg?alt=media',
        'status': 'UPLOADED',
        'uploaded_at': datetime.now(),
        'ai_confidence': 0.0
    })

    batch.commit()
    print("--- Seeding Complete: APP_002, ORDER_002, SMP_002 created ---")

if __name__ == "__main__":
    seed()
