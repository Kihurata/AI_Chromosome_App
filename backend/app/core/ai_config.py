from firebase_admin import firestore
import logging

logger = logging.getLogger(__name__)

def get_ai_server_url() -> str:
    """
    Fetches the AI Server URL from Firestore system configuration.
    Path: system_configs/ai_server -> field: url
    """
    try:
        db = firestore.client()
        doc_ref = db.collection('system_configs').document('ai_server')
        doc = doc_ref.get()
        
        if doc.exists:
            data = doc.to_dict()
            api_url = data.get('url')
            if api_url:
                logger.info(f"AI Server URL fetched: {api_url}")
                return api_url
            else:
                logger.warning("AI Server URL document exists but 'url' field is missing.")
        else:
            logger.warning("AI Server URL document 'system_configs/ai_server' not found.")
            
    except Exception as e:
        logger.error(f"Error fetching AI Server URL from Firestore: {e}")
        
    return ""
