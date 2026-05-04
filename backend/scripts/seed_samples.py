import firebase_admin
from firebase_admin import credentials, firestore
import datetime
import sys
import random

# Set encoding for Windows terminal
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

def seed_samples():
    # Initialize Firebase
    try:
        # Sử dụng đường dẫn tương đối từ gốc project
        cred = credentials.Certificate('backend/serviceAccountKey.json')
        firebase_admin.initialize_app(cred)
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return

    db = firestore.client()

    print("Seeding sample data to 'samples' collection...")

    mock_samples = [
        {
            'id': 'SAMPLE_001',
            'testOrderId': 'ORDER_101',
            'patientName': 'Nguyễn Văn Hải',
            'patientCode': 'BN_H001',
            'sampleType': 'Máu ngoại vi',
            'collectedBy': 'Điều dưỡng Minh',
            'collectedAt': datetime.datetime.now() - datetime.timedelta(days=1),
            'status': 'collected',
            'notes': 'Mẫu thu nhận tốt, không đông.',
        },
        {
            'id': 'SAMPLE_002',
            'testOrderId': 'ORDER_102',
            'patientName': 'Trần Thị Mai',
            'patientCode': 'BN_M002',
            'sampleType': 'Dịch ối',
            'collectedBy': 'Điều dưỡng Lan',
            'collectedAt': datetime.datetime.now() - datetime.timedelta(days=4),
            'status': 'culturing',
            'notes': 'Đang nuôi cấy, bình thường.',
        },
        {
            'id': 'SAMPLE_003',
            'testOrderId': 'ORDER_103',
            'patientName': 'Lê Văn Cường',
            'patientCode': 'BN_C003',
            'sampleType': 'Máu ngoại vi',
            'collectedBy': 'Điều dưỡng Minh',
            'collectedAt': datetime.datetime.now() - datetime.timedelta(days=7),
            'status': 'harvested',
            'notes': 'Đã thu hoạch thành công, chờ phân tích.',
        },
        {
            'id': 'SAMPLE_004',
            'testOrderId': 'ORDER_104',
            'patientName': 'Phạm Thu Hà',
            'patientCode': 'BN_H004',
            'sampleType': 'Gai nhau',
            'collectedBy': 'Điều dưỡng Lan',
            'collectedAt': datetime.datetime.now() - datetime.timedelta(days=2),
            'status': 'failed',
            'notes': 'Mẫu bị nhiễm khuẩn môi trường.',
        },
        {
            'id': 'SAMPLE_005',
            'testOrderId': 'ORDER_105',
            'patientName': 'Hoàng Gia Bảo',
            'patientCode': 'BN_B005',
            'sampleType': 'Máu ngoại vi',
            'collectedBy': 'Điều dưỡng Minh',
            'collectedAt': datetime.datetime.now() - datetime.timedelta(hours=12),
            'status': 'collected',
            'notes': 'Mẫu mới thu nhận sáng nay.',
        }
    ]

    for sample in mock_samples:
        doc_id = sample['id']
        # Xóa ID khỏi data trước khi ghi vào Firestore nếu bạn muốn dùng doc_id riêng
        # Ở đây tôi dùng luôn ID làm document name
        db.collection('samples').document(doc_id).set(sample)
        print(f"  - Created sample {doc_id} for {sample['patientName']}")

    print("\n✅ Success! 5 mock samples seeded successfully.")
    print("You can now check the 'Sample Management' page in the Flutter app.")

if __name__ == "__main__":
    seed_samples()
