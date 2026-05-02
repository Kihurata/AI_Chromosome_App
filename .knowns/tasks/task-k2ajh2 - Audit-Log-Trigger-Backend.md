---
id: k2ajh2
title: Audit Log Trigger (Backend)
status: done
priority: medium
labels: []
createdAt: '2026-04-29T09:22:10.099Z'
updatedAt: '2026-05-01T17:07:15.191Z'
timeSpent: 193
assignee: '@me'
spec: specs/specialist-dashboard
---
# Audit Log Trigger (Backend)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tạo trigger lắng nghe thay đổi status trên test_orders để ghi log vào audit_logs.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Create Audit Service**: Implement `backend/app/services/audit_service.py` to centralize writing to the `audit_logs` collection, following the schema defined in `ARCHITECTURE.md`.
2. **Refactor Firestore Listener**: Update `backend/app/services/firestore_listener.py` to watch all `test_orders` (instead of filtering for `ANALYZING`).
3. **Implement Status Tracking**:
   - Maintain an in-memory cache of order statuses.
   - On every document change, compare the new status with the cached value.
   - If changed, trigger a log entry via `AuditService`.
4. **Maintain AI Orchestration**: Ensure the existing logic that triggers AI analysis for `ANALYZING` status remains functional within the new universal listener.
5. **Testing**: Update `backend/scripts/test_reactive_sync.py` to verify that an `audit_logs` entry is correctly created upon status transition.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented universal status listener with audit logging. Every TestOrder status change is now recorded in the audit_logs collection. Verified with updated test script.
<!-- SECTION:NOTES:END -->

