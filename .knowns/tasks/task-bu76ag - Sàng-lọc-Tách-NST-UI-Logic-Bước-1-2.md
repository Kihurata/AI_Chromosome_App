---
id: bu76ag
title: 'Sàng lọc & Tách NST (UI/Logic) - Bước 1 & 2'
status: done
priority: high
labels:
  - ui
  - logic
  - workspace
createdAt: '2026-04-29T15:03:15.485Z'
updatedAt: '2026-04-29T18:05:49.767Z'
timeSpent: 42
spec: specs/specialist-workspace
fulfills:
  - FR-1
  - FR-2
  - AC-2
---
# Sàng lọc & Tách NST (UI/Logic) - Bước 1 & 2

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai màn hình Bước 1 (chọn ảnh sơ bộ) và Bước 2 (hiển thị NST bị dính, sử dụng Canvas/Drawing tools để cắt). Lưu toạ độ Bounding Box / Vector Polygon xuống Firestore khi nhấn Xác nhận.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create `ScreeningStep` (Bước 1) UI displaying a grid of placeholder images.
2. Create `SlicingStep` (Bước 2) UI displaying a main image and a `CustomPaint` overlay to collect polygon points for slicing.
3. Update `WorkspaceScreen` to replace the placeholders with `ScreeningStep` and `SlicingStep`.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented ScreeningStep with placeholder grid and selection logic. Implemented SlicingStep with CustomPaint for Lasso vector drawing and undo functionality. Included both into WorkspaceScreen.
<!-- SECTION:NOTES:END -->

