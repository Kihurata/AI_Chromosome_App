import logging
from firebase_admin import firestore
from datetime import datetime

logger = logging.getLogger(__name__)

class AuditService:
    def __init__(self):
        self.db = firestore.client()

    def log_status_change(self, order_id: str, old_status: str, new_status: str, user_id: str = None):
        """
        Logs a status change for a test order into the audit_logs collection.
        """
        try:
            log_ref = self.db.collection('audit_logs').document()
            
            log_entry = {
                "id": log_ref.id,
                "target_id": order_id,
                "action_type": "STATUS_CHANGE",
                "old_value": {"status": old_status},
                "new_value": {"status": new_status},
                "timestamp": firestore.SERVER_TIMESTAMP,
                "user_id": user_id
            }
            
            log_ref.set(log_entry)
            logger.info(f"Audit log created for order {order_id}: {old_status} -> {new_status}")
            return log_ref.id
            
        except Exception as e:
            logger.error(f"Failed to create audit log for {order_id}: {e}")
            return None

    def log_action(self, target_id: str, action_type: str, old_value: dict, new_value: dict, user_id: str = None):
        """
        Generic logging method for any action.
        """
        try:
            log_ref = self.db.collection('audit_logs').document()
            
            log_entry = {
                "id": log_ref.id,
                "target_id": target_id,
                "action_type": action_type,
                "old_value": old_value,
                "new_value": new_value,
                "timestamp": firestore.SERVER_TIMESTAMP,
                "user_id": user_id
            }
            
            log_ref.set(log_entry)
            return log_ref.id
        except Exception as e:
            logger.error(f"Failed to create generic audit log for {target_id}: {e}")
            return None
