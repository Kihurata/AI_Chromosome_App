---
id: ljp8lq
title: 'Implement AI Trigger & Processing State in Workspace Step 1'
status: in-progress
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-06T09:20:44.940Z'
updatedAt: '2026-05-06T09:31:05.275Z'
timeSpent: 0
spec: specs/specialist-dashboard-ai-trigger
fulfills:
  - AC-3
  - AC-4
  - AC-5
---
# Implement AI Trigger & Processing State in Workspace Step 1

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Thêm nút Phân tích AI vào ScreeningStep và hiển thị trạng thái đang xử lý cho các ảnh
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Nút Phân tích AI hiện lên khi có ảnh đã upload
- [x] #2 Nhấn nút sẽ gọi triggerAnalysis
- [x] #3 UI hiển thị các ảnh ở trạng thái loading (spinner/lottie) trong quá trình AI chạy
- [x] #4 UI cập nhật ảnh khi trạng thái chuyển sang Completed
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented AI Trigger button and processing state
Fixing DI error with WorkspaceCubit dependencies
<!-- SECTION:NOTES:END -->

