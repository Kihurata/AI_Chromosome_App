import os
import sys
import asyncio
import logging
import json
from datetime import datetime
from unittest.mock import patch, MagicMock

# Set Firebase Key Path BEFORE imports
os.environ["FIREBASE_KEY_PATH"] = os.path.join(os.path.dirname(__file__), "../serviceAccountKey.json")

# Add parent dir to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Import App Components
from app.core.firebase import init_firebase
init_firebase() # Ensure it's called early

from firebase_admin import firestore
from app.services.firestore_listener import start_order_listener
from app.services.orchestrator_service import OrchestratorService

# Setup Logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger("E2E-Test")

# Mock AI Response Data
MOCK_LABELME_DATA = {
    "version": "5.0.1",
    "flags": {},
    "shapes": [
        {
            "label": "1",
            "points": [[10, 10], [20, 10], [20, 30], [10, 30]],
            "group_id": None,
            "shape_type": "polygon",
            "flags": {}
        },
        {
            "label": "2",
            "points": [[50, 50], [70, 50], [70, 90], [50, 90]],
            "group_id": None,
            "shape_type": "polygon",
            "flags": {}
        }
    ],
    "imagePath": "test.jpg",
    "imageData": None,
    "imageHeight": 1000,
    "imageWidth": 1000
}

async def mock_post_response(*args, **kwargs):
    mock_resp = MagicMock()
    mock_resp.status_code = 200
    mock_resp.json.return_value = MOCK_LABELME_DATA
    return mock_resp

async def run_e2e_test():
    logger.info("--- Starting E2E AI Workflow Validation ---")
    
    db = firestore.client()
    order_id = f"E2E_ORDER_{int(datetime.now().timestamp())}"
    image_id = "E2E_IMG_001"
    
    # 1. Setup Test Data
    logger.info(f"Setting up test documents for {order_id}...")
    order_ref = db.collection('test_orders').document(order_id)
    img_ref = order_ref.collection('metaphase_images').document(image_id)
    
    order_ref.set({
        "status": "PENDING",
        "patient_name": "E2E Test Patient",
        "test_run": True,
        "createdAt": firestore.SERVER_TIMESTAMP
    })
    
    img_ref.set({
        "status": "UPLOADED",
        "raw_image_url": "https://example.com/test_image.jpg",
        "test_run": True,
        "createdAt": firestore.SERVER_TIMESTAMP
    })
    
    # 2. Start Listener in Background
    logger.info("Starting Firestore Listener...")
    listener_task = asyncio.create_task(start_order_listener())
    
    # Give listener a moment to initialize and capture initial state
    await asyncio.sleep(2)
    
    # 3. Trigger Analysis
    with patch("httpx.AsyncClient.post", side_effect=mock_post_response):
        logger.info(f"TRIGGER: Setting order {order_id} status to ANALYZING...")
        order_ref.update({"status": "ANALYZING"})
        
        # 4. Polling for Completion
        logger.info("Polling for results...")
        max_retries = 15
        success = False
        
        for i in range(max_retries):
            await asyncio.sleep(2)
            img_snap = img_ref.get()
            status = img_snap.to_dict().get("status")
            logger.info(f"[{i*2}s] MetaphaseImage Status: {status}")
            
            if status == "COMPLETED":
                logger.info("MATCH: Status reached COMPLETED.")
                success = True
                break
            elif status == "FAILED":
                logger.error("FAIL: Analysis failed.")
                break
                
        if not success:
            logger.error("TIMEOUT: Analysis did not complete in time.")
            listener_task.cancel()
            return
            
        # 5. Verification
        logger.info("Verifying Data Payload...")
        chroms = img_ref.collection('chromosomes').get()
        logger.info(f"Found {len(chroms)} chromosome documents.")
        assert len(chroms) == 2, f"Expected 2 chromosomes, found {len(chroms)}"
        
        # Check first chromosome
        c0 = chroms[0].to_dict()
        assert "bbox" in c0
        assert "coordinates" in c0
        assert c0["label"] in ["1", "2"]
        logger.info("Chromosome data structure verified.")
        
        # 6. Verify Audit Log
        logger.info("Verifying Audit Logs...")
        audit_logs = db.collection('audit_logs').where("target_id", "==", order_id).stream()
        logs_found = [log.to_dict() for log in audit_logs]
        logger.info(f"Found {len(logs_found)} audit entries.")
        assert any(l.get("new_value", {}).get("status") == "ANALYZING" for l in logs_found), "Missing ANALYZING audit log"
        logger.info("Audit logs verified.")
        
    # Cleanup
    logger.info("Cleaning up...")
    batch = db.batch()
    for c in chroms:
        batch.delete(c.reference)
    batch.delete(img_ref)
    batch.delete(order_ref)
    batch.commit()
    
    listener_task.cancel()
    logger.info("--- [SUCCESS] E2E AI Workflow Validated ---")

if __name__ == "__main__":
    asyncio.run(run_e2e_test())
