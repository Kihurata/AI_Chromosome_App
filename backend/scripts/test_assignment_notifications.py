import os
import sys
import time
import asyncio
from firebase_admin import firestore

# Add parent dir to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Set Firebase Key Path
os.environ["FIREBASE_KEY_PATH"] = "serviceAccountKey.json"

from app.core import firebase
db = firestore.client()

async def test_assignment_notifications():
    """
    Simulates a manager assigning an order to a specialist and checks 
    if the backend listener triggers a notification.
    """
    print("--- Testing Assignment Notifications ---")
    
    order_id = "ORDER_NOTIF_TEST"
    specialist_id = "SPEC_001"
    
    # 1. Setup Test Data
    order_ref = db.collection('test_orders').document(order_id)
    user_ref = db.collection('users').document(specialist_id)
    
    print("Setting up test user with mock FCM token...")
    user_ref.set({
        'full_name': 'Test Specialist',
        'role': 'specialist',
        'fcm_token': 'mock_fcm_token_123'
    })
    
    print("Setting up test order...")
    order_ref.set({
        'status': 'PENDING',
        'patient_name': 'Notification Patient',
        'specialist_id': None,
        'createdAt': firestore.SERVER_TIMESTAMP
    })
    
    print("Setup complete. specialist_id is None.")
    time.sleep(2)
    
    # 2. Trigger Notification by assigning specialist
    print(f"Assigning specialist {specialist_id} to order {order_id}...")
    order_ref.update({'specialist_id': specialist_id})
    
    print("Assignment triggered. Check backend logs for 'New assignment detected' and FCM send attempt.")
    print("Note: The FCM call will fail with the mock token, but the trigger logic will be verified.")
    
    time.sleep(5)
    print("Test complete. Please verify backend logs.")

if __name__ == "__main__":
    asyncio.run(test_assignment_notifications())
