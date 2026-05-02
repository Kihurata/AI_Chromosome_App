import firebase_admin
from firebase_admin import credentials, firestore
import datetime
import sys

# Set encoding for Windows terminal
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

def seed_mock_data():
    # Initialize Firebase
    try:
        cred = credentials.Certificate('backend/serviceAccountKey.json')
        firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return

    db = firestore.client()

    # 1. Tìm specialist đầu tiên
    print("Finding a specialist...")
    specialists = db.collection('users').where('role', '==', 'specialist').limit(1).get()
    
    if not specialists:
        print("No specialist found! Please create a user with role 'specialist' first.")
        return
    
    specialist = specialists[0]
    specialist_id = specialist.id
    specialist_ref = db.collection('users').document(specialist_id)
    print(f"Found specialist: {specialist.to_dict().get('full_name')} ({specialist_id})")

    # 2. Mock data mẫu
    mock_patients = [
        {'name': 'Nguyen Van A', 'code': 'BN1024'},
        {'name': 'Tran Thi B', 'code': 'BN1025'},
        {'name': 'Le Van C', 'code': 'BN1026'},
        {'name': 'Pham Minh D', 'code': 'BN1027'},
        {'name': 'Hoang Anh E', 'code': 'BN1028'},
    ]

    statuses = ['PENDING', 'ANALYZING', 'WAITING_APPROVAL', 'COMPLETED', 'PENDING']

    print(f"Seeding 5 mock orders for specialist {specialist_id}...")

    for i, p_data in enumerate(mock_patients):
        # Create Patient
        patient_ref = db.collection('patients').add({
            'full_name': p_data['name'],
            'code': p_data['code'],
            'gender': 'Nam' if i % 2 == 0 else 'Nữ',
            'birth_date': datetime.datetime(1985 + i, 5, 20),
            'created_at': firestore.SERVER_TIMESTAMP
        })[1]

        # Create Appointment
        appointment_ref = db.collection('appointments').add({
            'patient_id': patient_ref,
            'appointment_date': firestore.SERVER_TIMESTAMP,
            'status': 'COMPLETED',
            'reason': 'Khám di truyền',
            'created_at': firestore.SERVER_TIMESTAMP
        })[1]

        # Create Test Order
        db.collection('test_orders').add({
            'patient_id': patient_ref,
            'patient_name': p_data['name'],
            'patient_code': p_data['code'],
            'appointment_id': appointment_ref,
            'specialist_id': specialist_ref,
            'status': statuses[i],
            'created_at': firestore.SERVER_TIMESTAMP,
            'updated_at': firestore.SERVER_TIMESTAMP
        })
        print(f"  - Created order for {p_data['name']}")

    print("Success! Mock data seeded.")

if __name__ == "__main__":
    seed_mock_data()
