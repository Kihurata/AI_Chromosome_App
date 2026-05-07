---
id: mnfun7
title: 'Frontend: AI Analysis Trigger & Loading Overlay'
status: done
priority: high
labels:
  - from-spec
  - go-mode
  - frontend
createdAt: '2026-05-07T06:44:41.542Z'
updatedAt: '2026-05-07T06:48:43.235Z'
timeSpent: 159
spec: specs/frontend-ai-integration-phn-tch-ai
fulfills:
  - AC-1
  - AC-2
  - AC-3
  - AC-5
---
# Frontend: AI Analysis Trigger & Loading Overlay

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement the API call from frontend to trigger analysis, and show a full-screen loading overlay while listening to Firestore for status updates.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add `analyzeAllImages` method to `WorkspaceCubit` (or similar state manager).
- [x] #2 Call the backend API `POST /api/v1/orders/{test_order_id}/analyze`.
- [x] #3 Show full-screen loading overlay while `status == 'ANALYZING'`.
- [x] #4 Listen to Firestore updates for completion and remove overlay.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Updated `WorkspaceRepository` to make HTTP call. Added full screen loading overlay to `WorkspaceScreen`. Removed auto-navigation.
<!-- SECTION:NOTES:END -->

