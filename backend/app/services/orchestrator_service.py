import logging
import asyncio
from firebase_admin import firestore
from app.services.ai_client import AIClient
from app.services.data_mapper import map_labelme_to_chromosomes
import json
import re
from firebase_admin import storage
from datetime import timedelta

logger = logging.getLogger(__name__)

class OrchestratorService:
    def __init__(self):
        self.db = firestore.client()
        self.ai_client = AIClient()

    async def analyze_order(self, order_id: str):
        """
        Scans an order for images and initiates a SEQUENTIAL background analysis.
        Returns immediately to avoid frontend timeouts.
        """
        print(f"🔍 [BACKEND] Khởi chạy tiến trình phân tích cho đơn hàng: {order_id}")
        
        try:
            images_ref = self.db.collection('test_orders').document(order_id).collection('metaphase_images')
            images_all = list(images_ref.stream())
            
            # Filter images that need processing
            to_process = []
            for img_doc in images_all:
                status = img_doc.to_dict().get('status', 'UPLOADED')
                if status in ['UPLOADED', 'PENDING']:
                    to_process.append(img_doc)

            if not to_process:
                print(f"ℹ️ [BACKEND] Không có ảnh mới nào cần phân tích cho {order_id}")
                return 0

            # Start the sequential loop in the BACKGROUND
            asyncio.create_task(self._run_sequential_analysis(order_id, to_process))
            
            print(f"✅ [BACKEND] Đã bắt đầu tiến trình nền cho {len(to_process)} ảnh. API trả về ngay lập tức.")
            return len(to_process)
            
        except Exception as e:
            logger.error(f"Failed to trigger analysis for order {order_id}: {e}")
            return 0

    async def _run_sequential_analysis(self, order_id: str, image_docs: list):
        """
        Internal helper to run analysis one-by-one in the background.
        """
        print(f"⚙️ [BACKGROUND] Bắt đầu xử lý tuần tự {len(image_docs)} ảnh...")
        for img_doc in image_docs:
            img_data = img_doc.to_dict()
            image_id = img_doc.id
            raw_image_url = img_data.get('raw_image_url')
            
            if raw_image_url:
                print(f"🚀 [BACKGROUND] Đang xử lý: {image_id}")
                # Lock status
                img_doc.reference.update({
                    'status': 'PROCESSING',
                    'analysisStartedAt': firestore.SERVER_TIMESTAMP
                })
                
                # Await single analysis
                try:
                    await self.process_ai_analysis(order_id, image_id, raw_image_url)
                except Exception as e:
                    print(f"❌ [BACKGROUND] Lỗi khi xử lý ảnh {image_id}: {e}")
                    img_doc.reference.update({'status': 'FAILED'})
        
        print(f"🏁 [BACKGROUND] Hoàn thành toàn bộ {len(image_docs)} ảnh cho đơn hàng {order_id}")

    async def process_ai_analysis(self, order_id: str, image_id: str, image_url: str):
        """
        Handles the full AI analysis lifecycle for a single image:
        AI Call -> Mapping -> Bulk Persistence -> Status Update.
        """
        img_ref = self.db.collection('test_orders').document(order_id).collection('metaphase_images').document(image_id)
        
        try:
            logger.info(f"--- [AI START] Image: {image_id} ---")
            
            # Use image_id for the storage folder to ensure consistency across the system
            storage_path = f"test_orders/{order_id}/ai_predict/{image_id}/"
            logger.info(f"Generated storage_path: {storage_path}")

            ai_result = await self.ai_client.analyze_image(image_url, order_id=order_id, storage_path=storage_path)
            
            if not ai_result:
                raise Exception("AI Server returned empty result or timed out.")

            # 2. Map LabelMe JSON to Firestore Domain Objects
            chromosomes = map_labelme_to_chromosomes(ai_result, order_id, image_id)
            ai_image_url = ai_result.get('ai_image_url') or ai_result.get('annotated_image_url')
            confidence = ai_result.get('confidence', 0.0)
            
            # 3. Batch Persistence for Atomic Consistency
            batch = self.db.batch()
            chrom_collection = img_ref.collection('chromosomes')
            
            # Update chromosomes with ID before manifest generation
            for chrom_data in chromosomes:
                new_chrom_ref = chrom_collection.document()
                chrom_data['id'] = new_chrom_ref.id
                # Note: We'll set the data in the batch later after manifest generation
            
            # 4. Generate and Upload Manifest to Firebase Storage
            # This manifest will be used by the Frontend for Step 3
            try:
                await self._generate_and_upload_manifest(order_id, image_id, chromosomes)
            except Exception as manifest_e:
                logger.error(f"Failed to generate manifest: {manifest_e}")

            for chrom_data in chromosomes:
                ref = chrom_collection.document(chrom_data['id'])
                batch.set(ref, chrom_data)
            
            # 4. Final Transition: Set to COMPLETED
            update_data = {
                'status': 'COMPLETED',
                'ai_count': len(chromosomes),
                'ai_confidence': confidence,
                'ai_score': int(confidence * 100) if confidence <= 1.0 else int(confidence), # Chuyển thành thang điểm 100 nếu cần
                'ai_image_url': ai_image_url,
                'analysisCompletedAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            }
            if ai_image_url:
                update_data['ai_image_url'] = ai_image_url
                
            batch.update(img_ref, update_data)
            
            batch.commit()
            logger.info(f"--- [AI SUCCESS] Image: {image_id} | Chromosomes: {len(chromosomes)} ---")
            
        except Exception as e:
            logger.error(f"--- [AI FAILURE] Image: {image_id} | Error: {e} ---")
            try:
                # Update status to FAILED so UI can show error state
                img_ref.update({
                    'status': 'FAILED',
                    'error_message': str(e),
                    'updatedAt': firestore.SERVER_TIMESTAMP
                })
            except Exception as inner_e:
                logger.error(f"Failed to record error state for {image_id}: {inner_e}")

    async def _generate_and_upload_manifest(self, order_id: str, image_id: str, chromosomes: list):
        """
        Generates manifest.json containing chromosome data and signed URLs,
        then uploads it to the image's folder in Storage.
        """
        logger.info(f"Generating manifest for {image_id}...")
        bucket = storage.bucket()
        prefix = f"test_orders/{order_id}/ai_predict/{image_id}/"
        
        # 1. List blobs in the folder to match chromosomes with their image files
        blobs = list(bucket.list_blobs(prefix=prefix))
        
        # 2. Match each chromosome with a blob
        # Convention: AI Server saves cropped images as {label}_{original_index}.jpg or similar
        # For now, we'll try to find blobs that are not the manifest itself or the detection image
        manifest_entries = []
        
        for chrom in chromosomes:
            label = chrom.get('label', 'unknown')
            index = chrom.get('index', 0)
            
            # Look for a blob that matches this chromosome
            matched_blob = None
            for blob in blobs:
                if blob.name.endswith('.json') or 'detection' in blob.name:
                    continue
                
                # Match patterns like "11_1.png" or "X_2.png"
                blob_filename = blob.name.split('/')[-1]
                blob_match = re.search(r'([0-9]{1,2}|X|Y)_([0-9]+)', blob_filename)
                if blob_match:
                    b_label = blob_match.group(1)
                    b_index = blob_match.group(2)
                    # Check if it matches the current chromosome's label and index
                    if str(b_label) == str(label) and str(b_index) == str(index):
                        matched_blob = blob
                        break
                
                # Generic fallback if regex fails
                if f"{label}_{index}" in blob_filename:
                    matched_blob = blob
                    break
            
            if not matched_blob and blobs:
                # Fallback: if no exact match, try to find by index if blobs list is ordered
                # (This is risky but better than nothing if naming is inconsistent)
                remaining_blobs = [b for b in blobs if not b.name.endswith('.json') and 'detection' not in b.name]
                if index <= len(remaining_blobs):
                    matched_blob = remaining_blobs[index - 1]

            if matched_blob:
                # Generate a signed URL (valid for 7 days)
                url = matched_blob.generate_signed_url(expiration=timedelta(days=7))
                chrom['imageUrl'] = url
            else:
                chrom['imageUrl'] = ""
                
            # Prepare entry for JSON (sanitize for JSON serialization)
            entry = chrom.copy()
            if 'createdAt' in entry:
                entry['createdAt'] = entry['createdAt'].isoformat()
            manifest_entries.append(entry)

        # 3. Upload manifest.json
        manifest_path = f"{prefix}manifest.json"
        manifest_blob = bucket.blob(manifest_path)
        manifest_blob.upload_from_string(
            data=json.dumps(manifest_entries, indent=2),
            content_type='application/json'
        )
        logger.info(f"Manifest uploaded to {manifest_path}")
