import logging
from firebase_admin import messaging, firestore

logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        self.db = firestore.client()

    def send_to_user(self, user_id: str, title: str, body: str, data: dict = None):
        """
        Sends a push notification to a specific user by their UID.
        """
        try:
            # 1. Fetch user's FCM token
            user_doc = self.db.collection('users').document(user_id).get()
            if not user_doc.exists:
                logger.warning(f"User {user_id} not found. Cannot send notification.")
                return False
            
            user_data = user_doc.to_dict()
            token = user_data.get('fcm_token') or user_data.get('fcmToken')
            
            if not token:
                logger.warning(f"User {user_id} has no FCM token registered.")
                return False

            # 2. Construct message
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                token=token
            )

            # 3. Send message
            response = messaging.send(message)
            logger.info(f"Successfully sent notification to {user_id}: {response}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending notification to {user_id}: {e}")
            return False

    def notify_assignment(self, specialist_id: str, order_id: str, patient_name: str):
        """
        Notifies a specialist about a new test order assignment.
        """
        title = "📋 Phân công mới"
        body = f"Bạn đã được phân công xử lý phiếu xét nghiệm của bệnh nhân {patient_name}."
        data = {
            "type": "ASSIGNMENT",
            "orderId": order_id,
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
        
        return self.send_to_user(specialist_id, title, body, data)
