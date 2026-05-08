---
id: dua0ei
title: 'Implement Dirty State & Unsaved Changes Warning'
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-07T16:02:45.395Z'
updatedAt: '2026-05-07T16:51:47.702Z'
timeSpent: 0
spec: specs/workspace-step-3-karyogram-data-fetch
fulfills:
  - AC-4
  - AC-5
---
# Implement Dirty State & Unsaved Changes Warning

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add `isDirty` boolean to `WorkspaceState`. Set to true on drag-and-drop. Use `NotificationFactory` to show `AlertDialog` if user attempts to change steps or leave while `isDirty` is true.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add `isDirty` to WorkspaceState.
- [x] #2 Set `isDirty = true` in `assignChromosomeLabel`.
- [x] #3 Add `canPop` or warning mechanism using `NotificationFactory` when trying to change steps or go back while dirty.
<!-- AC:END -->

