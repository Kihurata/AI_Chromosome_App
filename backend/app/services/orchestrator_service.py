import logging
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
        Looks for images in an order that need analysis and starts them.
        """
        logger.info(f"Triggering analysis check for order {order_id}")
        
        # Get all images for this order
        images_ref = self.db.collection('test_orders').document(order_id).collection('metaphase_images')
        images = images_ref.where('status', '==', 'UPLOADED').stream()
        
        triggered_count = 0
        for img_doc in images:
            img_data = img_doc.to_dict()
            image_id = img_doc.id
            raw_image_url = img_data.get('raw_image_url')
            
            if raw_image_url:
                # Update status to PROCESSING immediately to prevent double triggers
                img_doc.reference.update({'status': 'PROCESSING'})
                # Process in background
                import asyncio
                asyncio.create_task(self.process_ai_analysis(order_id, image_id, raw_image_url))
                triggered_count += 1
        
        logger.info(f"Triggered {triggered_count} images for analysis in order {order_id}")
        return triggered_count

    async def process_ai_analysis(self, order_id: str, image_id: str, image_url: str):
        """
        Core background process for AI analysis and Firestore updates.
        """
        img_ref = self.db.collection('test_orders').document(order_id).collection('metaphase_images').document(image_id)
        
        try:
            logger.info(f"Starting AI Analysis for image {image_id}")
            # 1. Call AI Server
            ai_result = await self.ai_client.analyze_image(image_url)
            
            if not ai_result:
                logger.error(f"AI Analysis failed for image {image_id}")
                img_ref.update({'status': 'FAILED'})
                return

            # 2. Map results
            chromosomes = map_labelme_to_chromosomes(ai_result, order_id, image_id)
            
            # 3. Bulk Write to Firestore
            batch = self.db.batch()
            chrom_collection = img_ref.collection('chromosomes')
            
            for chrom_data in chromosomes:
                new_chrom_ref = chrom_collection.document()
                chrom_data['id'] = new_chrom_ref.id
                batch.set(new_chrom_ref, chrom_data)
            
            # 4. Update MetaphaseImage status and count
            batch.update(img_ref, {
                'status': 'COMPLETED',
                'ai_count': len(chromosomes),
                'updatedAt': firestore.SERVER_TIMESTAMP
            })
            
            batch.commit()
            logger.info(f"Successfully processed {len(chromosomes)} chromosomes for image {image_id}")
            
        except Exception as e:
            logger.error(f"Error in process_ai_analysis for {image_id}: {e}")
            try:
                img_ref.update({'status': 'FAILED'})
            except:
                pass
