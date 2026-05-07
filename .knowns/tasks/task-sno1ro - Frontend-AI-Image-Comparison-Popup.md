---
id: sno1ro
title: 'Frontend: AI Image Comparison Popup'
status: done
priority: medium
labels:
  - from-spec
  - go-mode
  - frontend
createdAt: '2026-05-07T06:44:41.597Z'
updatedAt: '2026-05-07T06:49:46.568Z'
timeSpent: 54
spec: specs/frontend-ai-integration-phn-tch-ai
fulfills:
  - AC-4
---
# Frontend: AI Image Comparison Popup

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a popup dialog showing the original image vs AI annotated image, including confidence score and chromosome count.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Create `ComparisonDialog` widget.
- [x] #2 Bind data: Original Image, AI Image, Confidence, Chromosome Count.
- [x] #3 Add `onTap` to the image card in step 1 to show the dialog if status is COMPLETED.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented ComparisonDialog widget and integrated it into screening_step using an eye icon button for completed images.
<!-- SECTION:NOTES:END -->

