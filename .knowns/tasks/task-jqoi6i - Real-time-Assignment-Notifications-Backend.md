---
id: jqoi6i
title: Real-time Assignment Notifications (Backend)
status: done
priority: medium
labels: []
createdAt: '2026-04-29T09:22:10.420Z'
updatedAt: '2026-05-01T17:10:43.516Z'
timeSpent: 90
assignee: '@me'
spec: specs/specialist-dashboard
---
# Real-time Assignment Notifications (Backend)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gửi thông báo FCM cho Specialist khi có phiếu xét nghiệm mới được phân công.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Create Notification Service**: Implement `backend/app/services/notification_service.py` to handle Firebase Cloud Messaging (FCM).
   - Fetch specialist FCM tokens from the `users` collection.
   - Send push notifications with relevant context (Patient Name, Order ID).
2. **Update Firestore Listener**: Extend the universal listener in `backend/app/services/firestore_listener.py` to:
   - Track `specialist_id` in the in-memory cache.
   - Detect when an order is assigned (transition from `None` to a UID).
   - Trigger the notification service automatically.
3. **Error Handling**: Ensure that if a specialist has no FCM token registered, the system logs a warning but doesn't crash the listener.
4. **Validation**: Create a test script `backend/scripts/test_assignment_notifications.py` to verify the assignment detection logic and mock/dry-run FCM delivery.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented real-time assignment notifications using FCM. The backend now listens for specialist_id changes on test_orders and notifies the specialist immediately. Verified trigger logic with a dedicated test script.
<!-- SECTION:NOTES:END -->

