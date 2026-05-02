import os
import sys
import logging
from firebase_admin import firestore, credentials, initialize_app

# Add parent dir to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Setup Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def test_bulk_persistence():
    print("--- [TEST] Bulk Persistence (WriteBatch) Verification ---")
    
    try:
        db = firestore.client()
    except ValueError:
        # Initialize if not already done
        key_path = os.getenv("FIREBASE_KEY_PATH", os.path.join(os.path.dirname(__file__), "../serviceAccountKey.json"))
        cred = credentials.Certificate(key_path)
        initialize_app(cred)
        db = firestore.client()

    order_id = "test_bulk_order"
    image_id = "test_bulk_image"
    
    order_ref = db.collection('test_orders').document(order_id)
    img_ref = order_ref.collection('metaphase_images').document(image_id)
    
    # Ensure parent documents exist
    print("Ensuring parent documents exist...")
    order_ref.set({"status": "ANALYZING", "test_run": True}, merge=True)
    img_ref.set({"status": "UPLOADED", "test_run": True}, merge=True)
    
    # 1. Prepare Batch (Mocking 50 chromosomes)
    print(f"Preparing batch for {image_id}...")
    batch = db.batch()
    chrom_collection = img_ref.collection('chromosomes')
    
    for i in range(50):
        chrom_ref = chrom_collection.document()
        batch.set(chrom_ref, {
            "index": i + 1,
            "label": str((i % 23) + 1),
            "status": "DETECTED",
            "test_run": True
        })
    
    # 2. Update Image Status in same batch
    batch.update(img_ref, {
        "status": "COMPLETED",
        "ai_count": 50,
        "test_run": True
    })
    
    # 3. Commit
    print("Committing batch...")
    batch.commit()
    print("Batch commit successful.")
    
    # 4. Verification
    print("Verifying documents in Firestore...")
    
    # Check image status
    img_snap = img_ref.get()
    assert img_snap.exists
    assert img_snap.to_dict().get("status") == "COMPLETED"
    assert img_snap.to_dict().get("ai_count") == 50
    
    # Check chromosomes count
    chroms = chrom_collection.where("test_run", "==", True).stream()
    count = sum(1 for _ in chroms)
    print(f"Found {count} chromosome documents.")
    assert count == 50
    
    # 5. Cleanup
    print("Cleaning up test documents...")
    cleanup_batch = db.batch()
    chroms_to_delete = chrom_collection.where("test_run", "==", True).stream()
    for doc in chroms_to_delete:
        cleanup_batch.delete(doc.reference)
    cleanup_batch.commit()
    
    print("\n[SUCCESS] Bulk Persistence logic is atomic and verified.")

if __name__ == "__main__":
    test_bulk_persistence()
