from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel
import logging
from app.services.orchestrator_service import OrchestratorService

router = APIRouter()
logger = logging.getLogger(__name__)
orchestrator_service = OrchestratorService()

class AnalyzeRequest(BaseModel):
    orderId: str
    imageId: str

@router.post("/analyze")
async def analyze_image_endpoint(request: AnalyzeRequest, background_tasks: BackgroundTasks):
    """
    Endpoint to trigger AI analysis for a metaphase image manually.
    """
    order_id = request.orderId
    image_id = request.imageId
    
    # Get image data to check existence and URL
    img_ref = orchestrator_service.db.collection('test_orders').document(order_id).collection('metaphase_images').document(image_id)
    img_doc = img_ref.get()
    
    if not img_doc.exists:
        raise HTTPException(status_code=404, detail="Metaphase image not found")
    
    img_data = img_doc.to_dict()
    raw_image_url = img_data.get('raw_image_url')
    
    if not raw_image_url:
        raise HTTPException(status_code=400, detail="Metaphase image has no raw_image_url")

    # Update status to PROCESSING immediately
    img_ref.update({'status': 'PROCESSING'})
    
    # Add to background tasks
    background_tasks.add_task(orchestrator_service.process_ai_analysis, order_id, image_id, raw_image_url)
    
@router.post("/v1/orders/{order_id}/analyze")
async def analyze_order_images_endpoint(order_id: str):
    """
    Endpoint to trigger AI analysis for all UPLOADED images in a specific order.
    """
    # Verify order exists
    order_ref = orchestrator_service.db.collection('test_orders').document(order_id)
    order_doc = order_ref.get()
    
    if not order_doc.exists:
        raise HTTPException(status_code=404, detail="Order not found")
        
    tasks_count = await orchestrator_service.analyze_order(order_id)
    
    return {
        "message": "Analysis started for order",
        "orderId": order_id,
        "tasksScheduled": tasks_count
    }
