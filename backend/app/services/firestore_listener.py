import logging
import asyncio
from firebase_admin import firestore
from app.services.orchestrator_service import OrchestratorService
from app.services.audit_service import AuditService
from app.services.notification_service import NotificationService

logger = logging.getLogger(__name__)
orchestrator_service = OrchestratorService()
audit_service = AuditService()
notification_service = NotificationService()

# In-memory cache to track order metadata across snapshots
# Format: { order_id: { 'status': str, 'specialist_id': str } }
order_metadata_cache = {}

async def start_order_listener():
    """
    Continuous listener for TestOrder changes.
    - Triggers AI Sync when status becomes 'ANALYZING'.
    - Logs all status transitions to audit_logs.
    - Sends notifications when a specialist is assigned.
    """
    db = firestore.client()
    orders_ref = db.collection('test_orders')
    loop = asyncio.get_running_loop()
    
    def on_snapshot(col_snapshot, changes, read_time):
        
        for change in changes:
            order_data = change.document.to_dict()
            def get_id(value):
                if value is None:
                    return None
                if hasattr(value, 'id'): 
                    return value.id
                if hasattr(value, 'path'):
                    return value.path.split('/')[-1]
                return str(value)

            order_id = change.document.id
            new_status = order_data.get('status')
            new_specialist_id = get_id(order_data.get('specialist_id'))
            patient_name = order_data.get('patient_name', 'Bệnh nhân')
            
            cached_data = order_metadata_cache.get(order_id, {})
            old_status = cached_data.get('status')
            old_specialist_id = get_id(cached_data.get('specialist_id'))

            # LOGGING: Theo dõi mọi sự thay đổi
            print(f"DEBUG: --- Snapshot Change Detected for Order: {order_id} ---")
            print(f"DEBUG: Type: {change.type.name} | Status: {old_status} -> {new_status} | Specialist: {old_specialist_id} -> {new_specialist_id}")
            
            # --- LOGIC XỬ LÝ ---
            
            # 1. Nếu là PHIẾU MỚI (ADDED)
            if change.type.name == 'ADDED':
                # Thông báo cho Manager nếu phiếu ở trạng thái chờ
                if new_status == 'PENDING':
                    print(f"DEBUG: Triggering NEW PENDING notification for {order_id}")
                    notification_service.notify_order_pending(order_id, patient_name)
                
                # Thông báo cho Manager nếu có phiếu đang chờ duyệt (khi backend vừa khởi động)
                elif new_status == 'WAITING_APPROVAL':
                    print(f"DEBUG: Initial Catch: Analysis ready for {order_id}")
                    notification_service.notify_analysis_ready(order_id, patient_name)

                # Thông báo cho Clinician nếu có phiếu đã hoàn thành (khi backend vừa khởi động)
                elif new_status == 'COMPLETED':
                    clinician_id = get_id(order_data.get('clinician_id'))
                    if clinician_id:
                        print(f"DEBUG: Initial Catch: Order COMPLETED. Notifying clinician: {clinician_id}")
                        notification_service.notify_order_completed(clinician_id, order_id, patient_name)
                
                # Thông báo cho Specialist nếu đã được chỉ định và phiếu đang trong quá trình xử lý
                if new_specialist_id and new_status in ['ANALYZING', 'IN_PROGRESS']:
                    print(f"DEBUG: Triggering ASSIGNMENT notification (Initial ADDED) for {new_specialist_id} on {order_id}")
                    notification_service.notify_assignment(new_specialist_id, order_id, patient_name)

            # 2. Nếu là PHIẾU CẬP NHẬT (MODIFIED)
            elif change.type.name == 'MODIFIED':
                # A. Phát hiện thay đổi trạng thái
                if old_status != new_status:
                    print(f"DEBUG: Status changed: {old_status} -> {new_status}")
                    
                    # Audit Log
                    audit_service.log_status_change(order_id, old_status, new_status, new_specialist_id)

                    # Trigger các loại thông báo dựa trên trạng thái mới
                    if new_status == 'PENDING':
                        notification_service.notify_order_pending(order_id, patient_name)
                    elif new_status in ['ANALYZING', 'IN_PROGRESS']:
                        print(f"DEBUG: Starting analysis trigger for {order_id}")
                        if loop.is_running():
                            loop.create_task(orchestrator_service.analyze_order(order_id))
                        else:
                            asyncio.run(orchestrator_service.analyze_order(order_id))
                    elif new_status == 'WAITING_APPROVAL':
                        print(f"DEBUG: Notify: Analysis ready for {order_id}")
                        notification_service.notify_analysis_ready(order_id, patient_name)
                    elif new_status == 'COMPLETED':
                        clinician_id = get_id(order_data.get('clinician_id'))
                        print(f"DEBUG: Notify: Order COMPLETED. Notifying clinician: {clinician_id}")
                        notification_service.notify_order_completed(clinician_id, order_id, patient_name)
                    elif new_status == 'REJECTED':
                        print(f"DEBUG: Notify: Order REJECTED for {new_specialist_id}")
                        notification_service.notify_order_rejected(new_specialist_id, order_id, patient_name)

                # B. Phát hiện thay đổi Specialist (Phân công lại)
                if old_specialist_id != new_specialist_id and new_specialist_id:
                    print(f"DEBUG: Detecting NEW ASSIGNMENT: {old_specialist_id} -> {new_specialist_id}")
                    notification_service.notify_assignment(new_specialist_id, order_id, patient_name)

            # Cập nhật Cache sau khi đã xử lý xong logic
            order_metadata_cache[order_id] = {
                'status': new_status,
                'specialist_id': new_specialist_id
            }

    # Watch all test orders
    # We don't filter here to ensure we catch every transition for auditing.
    query_watch = orders_ref.on_snapshot(on_snapshot)
    
    print("DEBUG: Firestore Universal Order Listener started (AI + Auditing).")
    
    while True:
        await asyncio.sleep(3600)
