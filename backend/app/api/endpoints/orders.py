from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import logging
from firebase_admin import firestore

from app.services.diagnostic_service import DiagnosticService

router = APIRouter()
logger = logging.getLogger(__name__)
diagnostic_service = DiagnosticService()

class ChromosomeSaveItem(BaseModel):
    id: str
    label: str
    image_url: Optional[str] = None

class KaryogramSaveRequest(BaseModel):
    selected_image_id: str
    chromosomes: List[ChromosomeSaveItem]

@router.post("/v1/orders/{order_id}/karyogram/save")
async def save_karyogram(order_id: str, request: KaryogramSaveRequest):
    """
    Saves the edited karyogram data and generates AI suggestions for Step 4.
    """
    try:
        db = firestore.client()
        batch = db.batch()
        
        # Reference to the image's chromosomes subcollection
        chromosomes_ref = db.collection('test_orders').document(order_id) \
                            .collection('metaphase_images').document(request.selected_image_id) \
                            .collection('chromosomes')
        
        chromosome_dicts = []
        for item in request.chromosomes:
            doc_ref = chromosomes_ref.document(item.id)
            
            data = {
                'label': item.label,
                'status': 'VERIFIED',
                'updated_at': firestore.SERVER_TIMESTAMP
            }
            
            if item.image_url:
                data['image_url'] = item.image_url
                
            batch.set(doc_ref, data, merge=True)
            chromosome_dicts.append({"label": item.label})
            
        batch.commit()
        
        # Generate AI suggestions based on saved labels
        suggestions = diagnostic_service.analyze(chromosome_dicts)
        
        # Update the parent image status and add suggestions
        db.collection('test_orders').document(order_id) \
          .collection('metaphase_images').document(request.selected_image_id) \
          .update({
              'status': 'ANALYZED',
              'karyogram_saved': True,
              'ai_suggestions': suggestions
          })
          
        return {
            "message": "Karyogram saved successfully",
            "suggestions": suggestions
        }
        
    except Exception as e:
        logger.error(f"Error saving karyogram: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")
