import logging
from firebase_admin import messaging, firestore

logger = logging.getLogger(__name__)

class NotificationService:
    def __init__(self):
        self.db = firestore.client()

    def send_to_user(self, user_id: str, title: str, body: str, type: str = "DEFAULT", related_id: str = None, data: dict = None):
        """
        Sends a push notification to a specific user by their UID.
        """
        try:
            # Debug log
            logger.info(f"Attempting to send notification to User ID: '{user_id}'")
            
            # 1. Fetch user's FCM token
            user_doc = self.db.collection('users').document(user_id).get()
            if not user_doc.exists:
                logger.warning(f"User '{user_id}' not found in 'users' collection. Cannot send notification.")
                return False
            
            user_data = user_doc.to_dict()
            token = user_data.get('fcm_token') or user_data.get('fcmToken')
            
            if not token:
                logger.warning(f"User {user_id} has no FCM token registered.")
                return False

            # 2. Construct message (Data-only for better control in Web Foreground)
            payload = {
                **(data or {}),
                "type": type,
                "title": title,
                "body": body
            }
            if related_id:
                payload["relatedId"] = related_id

            message = messaging.Message(
                data=payload,
                token=token,
                android=messaging.AndroidConfig(
                    notification=messaging.AndroidNotification(
                        sound="default",
                        click_action="FLUTTER_NOTIFICATION_CLICK"
                    )
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(sound="default")
                    )
                )
            )

            # 3. Send message
            response = messaging.send(message)
            logger.info(f"Successfully sent {type} notification to {user_id}: {response}")
            return True
            
        except Exception as e:
            logger.error(f"Error sending notification to {user_id}: {e}")
            return False

    def send_to_role(self, role: str, title: str, body: str, type: str = "DEFAULT", related_id: str = None, data: dict = None):
        """
        Sends push notifications to all users with a specific role.
        """
        try:
            print(f"DEBUG: send_to_role triggered for role: {role}")
            users_ref = self.db.collection('users').where('role', '==', role).stream()
            count = 0
            for user in users_ref:
                print(f"DEBUG: Found user {user.id} for role {role}. Sending...")
                self.send_to_user(user.id, title, body, type, related_id, data)
                count += 1
            print(f"DEBUG: Broadcasted {type} notification to {count} users with role: {role}")
            return True
        except Exception as e:
            logger.error(f"Error sending to role {role}: {e}")
            return False

    def notify_assignment(self, specialist_id: str, order_id: str, patient_name: str):
        """Notifies a specialist about a new test order assignment."""
        return self.send_to_user(
            user_id=specialist_id,
            title="📋 Phân công mới",
            body=f"Bạn đã được phân công xử lý phiếu xét nghiệm của bệnh nhân {patient_name}.",
            type="ORDER_ASSIGNED",
            related_id=order_id
        )

    def notify_order_pending(self, order_id: str, patient_name: str):
        """Notifies managers about a new pending test order."""
        return self.send_to_role(
            role="manager",
            title="🆕 Phiếu xét nghiệm mới",
            body=f"Có phiếu xét nghiệm mới cho bệnh nhân {patient_name} đang chờ xử lý.",
            type="ORDER_PENDING",
            related_id=order_id
        )

    def notify_analysis_ready(self, order_id: str, patient_name: str):
        """Notifies managers that an analysis is waiting for approval."""
        return self.send_to_role(
            role="manager",
            title="⚖️ Chờ phê duyệt",
            body=f"Kết quả phân tích của bệnh nhân {patient_name} đang chờ bạn phê duyệt.",
            type="ANALYSIS_READY",
            related_id=order_id
        )

    def notify_order_completed(self, clinician_id: str, order_id: str, patient_name: str):
        """Notifies the clinician that the test result is finalized."""
        if not clinician_id: return False
        return self.send_to_user(
            user_id=clinician_id,
            title="✅ Kết quả hoàn tất",
            body=f"Phiếu xét nghiệm của bệnh nhân {patient_name} đã hoàn tất và có kết quả cuối cùng.",
            type="ORDER_COMPLETED",
            related_id=order_id
        )

    def notify_order_rejected(self, specialist_id: str, order_id: str, patient_name: str):
        """Notifies the specialist that their analysis was rejected by the manager."""
        if not specialist_id: return False
        return self.send_to_user(
            user_id=specialist_id,
            title="❌ Kết quả bị từ chối",
            body=f"Phân tích cho bệnh nhân {patient_name} đã bị từ chối. Vui lòng kiểm tra và chỉnh sửa lại.",
            type="ORDER_REJECTED",
            related_id=order_id
        )
