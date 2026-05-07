import logging
import asyncio
from firebase_admin import firestore
from app.services.ai_client import AIClient
from app.services.data_mapper import map_labelme_to_chromosomes

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
            
            # 1. Call AI Server (Timeout handled inside AIClient)
            # Extract filename from raw_image_url to keep same naming in ai_predict folder
            # raw_image_url format: .../test_orders%2F{order_id}%2Fraw%2F{filename}?alt=media
            import urllib.parse
            path = urllib.parse.urlparse(image_url).path
            filename = path.split('%2F')[-1] if '%2F' in path else f"{image_id}.jpg"
            
            storage_path = f"test_orders/{order_id}/ai_predict/{filename}"
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
            
            for chrom_data in chromosomes:
                new_chrom_ref = chrom_collection.document()
                chrom_data['id'] = new_chrom_ref.id
                batch.set(new_chrom_ref, chrom_data)
            
            # 4. Final Transition: Set to COMPLETED
            update_data = {
                'status': 'COMPLETED',
                'ai_count': len(chromosomes),
                'ai_confidence': confidence,
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
