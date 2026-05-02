---
id: 8b2oeh
title: 'Drag & Drop NST đồ (UI/Logic) - Bước 3'
status: done
priority: high
labels:
  - ui
  - logic
  - workspace
  - performance
createdAt: '2026-04-29T15:03:16.548Z'
updatedAt: '2026-04-29T18:11:01.506Z'
timeSpent: 139
spec: specs/specialist-workspace
fulfills:
  - FR-3
  - AC-3
  - NFR-1
---
# Drag & Drop NST đồ (UI/Logic) - Bước 3

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai giao diện Grid và Drag & Drop cho lưới NST chuẩn ở Bước 3. Áp dụng Optimistic UI và RxDart (Debounce 1.5s) để auto-save toạ độ từng NST lên Firestore sau khi thả chuột. Sử dụng cơ chế Image Caching (Image.network) của hệ điều hành.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create `KaryogramStep` widget for Step 3 using `Draggable` and `DragTarget` for chromosome matching.
2. Structure the view with a pool of unassigned chromosomes and a Karyotype grid (22 pairs + XY/XX).
3. Implement the drag and drop logic to update local state via `WorkspaceCubit` immediately (Optimistic UI) which triggers debounced auto-saves to Firestore.
4. Add `KaryogramStep` to `WorkspaceScreen`.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented KaryogramStep using Draggable and DragTarget. Added assignChromosomeLabel to WorkspaceCubit for Optimistic UI drag-and-drop updates, which also syncs via usecase. Fixed compilation error from a previous session related to RejectKaryotypeResult taking a comment argument.
<!-- SECTION:NOTES:END -->

