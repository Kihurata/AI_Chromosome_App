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

async def test_reactive_sync():
    """
    Simulates the Specialist clicking 'Start' and checks if the backend 
    listener triggers the AI analysis automatically.
    
    NOTE: The backend server MUST be running (npm run dev or uvicorn main:app)
    """
    print("--- Testing Reactive AI Synchronization ---")
    
    order_id = "ORDER_TEST_SYNC"
    image_id = "IMG_TEST_SYNC"
    
    # 1. Setup Test Data
    order_ref = db.collection('test_orders').document(order_id)
    img_ref = order_ref.collection('metaphase_images').document(image_id)
    
    print("Setting up test order and image...")
    order_ref.set({
        'status': 'PENDING',
        'patientName': 'Test Sync Patient',
        'createdAt': firestore.SERVER_TIMESTAMP
    })
    
    img_ref.set({
        'status': 'UPLOADED',
        'raw_image_url': 'https://firebasestorage.googleapis.com/v0/b/chromosome-app.appspot.com/o/samples%2Ftest_metaphase.jpg?alt=media',
        'createdAt': firestore.SERVER_TIMESTAMP
    })
    
    print("Setup complete. Status is PENDING.")
    time.sleep(2)
    
    # 2. Trigger Sync by updating TestOrder status to ANALYZING
    print(f"Updating order {order_id} to ANALYZING (Simulating 'Start' button)...")
    order_ref.update({'status': 'ANALYZING'})
    
    # 3. Poll MetaphaseImage for PROCESSING status change
    print("Polling metaphase_image for status change triggered by backend listener...")
    success = False
    for i in range(15):
        time.sleep(2)
        doc = img_ref.get()
        status = doc.to_dict().get('status')
        print(f"[{i*2}s] MetaphaseImage status: {status}")
        
        if status in ['PROCESSING', 'COMPLETED']:
            print(f"SUCCESS: Backend listener triggered analysis (status={status})")
            success = True
            break
        if status == 'FAILED':
            print("INFO: Analysis failed, but trigger was successful.")
            success = True
            break
            
    if not success:
        print("FAIL: Backend listener did not trigger analysis within 30s.")
        return

    # 4. Check Audit Logs
    print("Checking audit_logs collection...")
    logs = db.collection('audit_logs').where('target_id', '==', order_id).stream()
    log_found = False
    for log in logs:
        log_data = log.to_dict()
        print(f"Found Audit Log: {log_data['old_value'].get('status')} -> {log_data['new_value'].get('status')}")
        if log_data['new_value'].get('status') == 'ANALYZING':
            log_found = True
    
    if log_found:
        print("SUCCESS: Audit log entry verified.")
    else:
        print("FAIL: No audit log entry found for 'ANALYZING' transition.")

if __name__ == "__main__":
    asyncio.run(test_reactive_sync())
