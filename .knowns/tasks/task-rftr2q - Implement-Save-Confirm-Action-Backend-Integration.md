---
id: rftr2q
title: 'Implement Save/Confirm Action & Backend Integration'
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-07T16:02:45.460Z'
updatedAt: '2026-05-07T16:51:47.791Z'
timeSpent: 0
spec: specs/workspace-step-3-karyogram-data-fetch
fulfills:
  - AC-6
---
# Implement Save/Confirm Action & Backend Integration

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement "Save / Confirm" action in Step 3. Send a request to FastAPI backend to perform secure copy/delete operation in Firebase Storage to rename modified files. Reset `isDirty` to false.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add Save button in KaryogramStep.
- [x] #2 Create `submitKaryogramLayout` usecase/endpoint integration.
- [x] #3 On successful save, set `isDirty = false`.
<!-- AC:END -->

