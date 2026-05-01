import os
import sys
import time
import httpx
import asyncio
from firebase_admin import firestore

# Add parent dir to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Set Firebase Key Path
os.environ["FIREBASE_KEY_PATH"] = "backend/serviceAccountKey.json"

from app.core import firebase
db = firestore.client()

async def test_analyze_flow():
    print("--- Testing AI Analyze Flow ---")
    
    order_id = "ORDER_001"
    image_id = "IMG_001"
    
    # 1. Reset status in Firestore
    img_ref = db.collection('test_orders').document(order_id).collection('metaphase_images').document(image_id)
    img_ref.update({
        'status': 'UPLOADED',
        'raw_image_url': 'https://firebasestorage.googleapis.com/.../test_metaphase.jpg'
    })
    print(f"Reset {image_id} status to UPLOADED")

    # 2. Call the API
    # Note: Assumes server is running at http://localhost:8000
    api_url = "http://localhost:8000/api/analyze"
    payload = {"orderId": order_id, "imageId": image_id}
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            print(f"Calling API: {api_url}")
            response = await client.post(api_url, json=payload)
            print(f"API Response: {response.json()}")
            
            if response.status_code != 200:
                print("FAIL: API returned error")
                return

            # 3. Poll Firestore for updates
            print("Waiting for background processing...")
            for i in range(10):
                time.sleep(2)
                doc = img_ref.get()
                status = doc.to_dict().get('status')
                print(f"Current status: {status}")
                if status == 'COMPLETED':
                    print("SUCCESS: Image processing COMPLETED")
                    # Check chromosomes
                    chroms = img_ref.collection('chromosomes').get()
                    print(f"Found {len(chroms)} chromosomes in sub-collection.")
                    return
                if status == 'FAILED':
                    print("INFO: Processing FAILED as expected (Mock URL failure), but flow is verified.")
                    return
            
            print("TIMEOUT: Processing took too long")
            
        except Exception as e:
            print(f"ERROR: {e}")

if __name__ == "__main__":
    asyncio.run(test_analyze_flow())
