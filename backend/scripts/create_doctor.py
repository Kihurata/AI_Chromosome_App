import os
import sys
import argparse
import firebase_admin
from firebase_admin import credentials, auth, firestore
from datetime import datetime

# Add parent dir to path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

def create_doctor(email, password, full_name, specialty, department_id):
    # Initialize Firebase
    key_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    
    print(f"--- Creating Doctor Account: {email} ---")
    
    try:
        # 1. Create Auth User
        user = auth.create_user(
            email=email,
            password=password,
            display_name=full_name
        )
        uid = user.uid
        print(f"Successfully created Auth user with UID: {uid}")
        
        # 2. Create Firestore User Document
        user_ref = db.collection('users').document(uid)
        user_ref.set({
            'uid': uid,
            'email': email,
            'full_name': full_name,
            'role': 'specialist',
            'status': 'active',
            'created_at': datetime.now()
        })
        
        # 3. Create Firestore Doctor Profile
        doctor_ref = db.collection('doctors').document(uid)
        doctor_ref.set({
            'id': uid,
            'specialty': specialty,
            'department_id': department_id,
            'created_at': datetime.now()
        })
        
        print(f"Successfully linked Firestore profile for Doctor: {full_name}")
        print("--- Registration Complete ---")
        
    except Exception as e:
        print(f"Error creating doctor: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create a new Doctor account.')
    parser.add_argument('--email', required=True, help='Doctor email')
    parser.add_argument('--password', required=True, help='Doctor password')
    parser.add_argument('--name', required=True, help='Full name')
    parser.add_argument('--specialty', default='Di truyền học', help='Specialty field')
    parser.add_argument('--dept', default='DEPT_01', help='Department ID')
    
    args = parser.parse_args()
    create_doctor(args.email, args.password, args.name, args.specialty, args.dept)
