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
            order_id = change.document.id
            new_status = order_data.get('status')
            new_specialist_id = order_data.get('specialist_id')
            patient_name = order_data.get('patient_name', 'Bệnh nhân')
            
            cached_data = order_metadata_cache.get(order_id, {})
            old_status = cached_data.get('status')
            old_specialist_id = cached_data.get('specialist_id')
            
            # Update Cache
            order_metadata_cache[order_id] = {
                'status': new_status,
                'specialist_id': new_specialist_id
            }
            
            # Skip logic if it's the first time we see this order (initial load)
            if old_status is None and old_specialist_id is None:
                continue

            # 1. Detect Status Change
            if old_status != new_status:
                logger.info(f"Status change for {order_id}: {old_status} -> {new_status}")
                
                # Create Audit Log
                audit_service.log_status_change(
                    order_id=order_id,
                    old_status=old_status,
                    new_status=new_status,
                    user_id=new_specialist_id
                )

                # Trigger AI Analysis if status is ANALYZING
                if new_status == 'ANALYZING':
                    logger.info(f"Triggering AI Orchestrator for order {order_id}")
                    if loop.is_running():
                        loop.create_task(orchestrator_service.trigger_analysis_for_order(order_id))
                    else:
                        asyncio.run(orchestrator_service.trigger_analysis_for_order(order_id))

            # 2. Detect Assignment Change
            if old_specialist_id != new_specialist_id and new_specialist_id is not None:
                logger.info(f"New assignment detected for {order_id}: -> {new_specialist_id}")
                
                # Send Push Notification
                notification_service.notify_assignment(
                    specialist_id=new_specialist_id,
                    order_id=order_id,
                    patient_name=patient_name
                )

    # Watch all test orders
    # We don't filter here to ensure we catch every transition for auditing.
    query_watch = orders_ref.on_snapshot(on_snapshot)
    
    logger.info("Firestore Universal Order Listener started (AI + Auditing).")
    
    while True:
        await asyncio.sleep(3600)
