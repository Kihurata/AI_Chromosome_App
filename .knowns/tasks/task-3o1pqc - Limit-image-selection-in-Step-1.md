---
id: 3o1pqc
title: Limit image selection in Step 1
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-07T16:02:44.457Z'
updatedAt: '2026-05-07T16:04:08.432Z'
timeSpent: 64
spec: specs/workspace-step-3-karyogram-data-fetch
fulfills:
  - AC-1
---
# Limit image selection in Step 1

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Modify `WorkspaceCubit` to only allow a maximum of 1 `selectedImageId`. If a user clicks a new image in Step 1, it replaces the currently selected image.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Update `toggleImageSelection` in WorkspaceCubit to select exactly 1 image.
- [x] #2 Update ScreeningStep UI to reflect single selection behavior (if any UI changes are needed).
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Update `WorkspaceState` and `WorkspaceCubit` in `d:\AI_Chromosome_App\frontend\lib\logic\bloc\workspace\workspace_cubit.dart`. Change `toggleImageSelection` to replace the list with just the selected image, instead of toggling/appending.
2. Update `ScreeningStep` in `d:\AI_Chromosome_App\frontend\lib\presentation\screens\workspace\steps\screening_step.dart` if needed. (Currently it checks if list contains the image. That logic is still fine, it will just visually select only one at a time).
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Updated WorkspaceCubit to use a single image list instead of toggling 3 max. Updated ScreeningStep UI text and disabled opacity logic.
<!-- SECTION:NOTES:END -->

