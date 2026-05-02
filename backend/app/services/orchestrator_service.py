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

    async def trigger_analysis_for_order(self, order_id: str):
        """
        Scans an order for 'UPLOADED' images and initiates background AI analysis tasks.
        """
        logger.info(f"Checking for images requiring AI analysis in order: {order_id}")
        
        try:
            # Get all images for this order
            images_ref = self.db.collection('test_orders').document(order_id).collection('metaphase_images')
            # Only process images that haven't been touched by AI yet
            images = images_ref.where('status', '==', 'UPLOADED').stream()
            
            tasks = []
            for img_doc in images:
                img_data = img_doc.to_dict()
                image_id = img_doc.id
                raw_image_url = img_data.get('raw_image_url')
                
                if raw_image_url:
                    # 1. Immediate State Lock: Set to PROCESSING to prevent concurrent triggers
                    img_doc.reference.update({
                        'status': 'PROCESSING',
                        'analysisStartedAt': firestore.SERVER_TIMESTAMP
                    })
                    
                    # 2. Schedule Background Task
                    # Note: We don't 'await' here because we want the listener to return quickly
                    task = asyncio.create_task(self.process_ai_analysis(order_id, image_id, raw_image_url))
                    tasks.append(task)
            
            if tasks:
                logger.info(f"Successfully scheduled {len(tasks)} AI analysis tasks for order {order_id}")
            else:
                logger.info(f"No pending images found for order {order_id}")
                
            return len(tasks)
            
        except Exception as e:
            logger.error(f"Failed to trigger analysis for order {order_id}: {e}")
            return 0

    async def process_ai_analysis(self, order_id: str, image_id: str, image_url: str):
        """
        Handles the full AI analysis lifecycle for a single image:
        AI Call -> Mapping -> Bulk Persistence -> Status Update.
        """
        img_ref = self.db.collection('test_orders').document(order_id).collection('metaphase_images').document(image_id)
        
        try:
            logger.info(f"--- [AI START] Image: {image_id} ---")
            
            # 1. Call AI Server (Timeout handled inside AIClient)
            ai_result = await self.ai_client.analyze_image(image_url)
            
            if not ai_result:
                raise Exception("AI Server returned empty result or timed out.")

            # 2. Map LabelMe JSON to Firestore Domain Objects
            chromosomes = map_labelme_to_chromosomes(ai_result, order_id, image_id)
            
            # 3. Batch Persistence for Atomic Consistency
            # We use a batch to ensure the image status and its chromosomes are updated together.
            batch = self.db.batch()
            chrom_collection = img_ref.collection('chromosomes')
            
            # Clear existing chromosomes if any (to allow retries/re-processing)
            # Note: For large collections, this would need a separate deletion logic.
            # In this context, we assume it's the first run or cleanup was handled.
            
            for chrom_data in chromosomes:
                new_chrom_ref = chrom_collection.document()
                chrom_data['id'] = new_chrom_ref.id
                batch.set(new_chrom_ref, chrom_data)
            
            # 4. Final Transition: Set to COMPLETED
            batch.update(img_ref, {
                'status': 'COMPLETED',
                'ai_count': len(chromosomes),
                'analysisCompletedAt': firestore.SERVER_TIMESTAMP,
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            
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
