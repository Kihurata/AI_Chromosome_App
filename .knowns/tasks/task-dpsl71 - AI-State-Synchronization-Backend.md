---
id: dpsl71
title: AI State Synchronization (Backend)
status: done
priority: high
labels: []
createdAt: '2026-04-29T09:22:10.534Z'
updatedAt: '2026-05-01T17:01:23.861Z'
timeSpent: 330
assignee: '@me'
spec: specs/specialist-dashboard
---
# AI State Synchronization (Backend)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Đảm bảo AI Orchestrator được kích hoạt đúng lúc khi Specialist bắt đầu phân tích. Phụ thuộc vào @task-yliqkd.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Refactor Orchestrator Logic**: Extract core analysis logic from `app/api/endpoints/orchestrator.py` into `app/services/orchestrator_service.py` to make it reusable for both API and Listener triggers.
2. **Create Firestore Listener**: Implement `app/services/firestore_listener.py` to watch the `test_orders` collection. When an order status becomes `ANALYZING`, trigger the analysis service for its `metaphase_images`.
3. **Integration**: Register the listener in `backend/main.py` startup event to ensure it runs continuously in the background.
4. **Validation**: Add checks to only trigger AI for images with status `UPLOADED` and prevent redundant processing.
5. **Testing**: Verify end-to-end sync using a test script that simulates the Specialist Dashboard status update.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented reactive Firestore listener to trigger AI orchestrator when order status changes to ANALYZING. Refactored orchestrator logic into a service for reusability. Verified with test script.
<!-- SECTION:NOTES:END -->

