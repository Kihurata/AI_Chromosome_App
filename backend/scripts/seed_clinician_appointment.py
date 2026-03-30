import os
import sys
from datetime import datetime

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import firebase_admin
from firebase_admin import credentials, firestore

def seed_appointment():
    key_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    
    # Check if patient exists
    p_ref = db.collection('patients').document('PAT_001')
    
    # Generate new Appointment
    uid = 'zOK3i6VFdjd7IbCmNOO9EYzaR8F3' # clinician1
    app_ref = db.collection('appointments').document('APP_CLINICIAN_001')
    app_ref.set({
        'id': 'APP_CLINICIAN_001',
        'patient_id': p_ref,
        'patient_name': 'Patient Alpha',
        'doctor_id': db.document(f'doctors/{uid}'),
        'doctor_name': 'Dr. Clinician',
        'appointment_date': datetime.now(),
        'status': 'scheduled',
        'reason': 'Khám sức khoẻ tổng quát định kỳ'
    })
    
    print("Seeded appointment for Dr. Clinician successfully.")

if __name__ == "__main__":
    seed_appointment()
