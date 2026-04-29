---
id: wcfgkr
title: 'Actions & Navigation Integration (Integration)'
status: todo
priority: medium
labels: []
createdAt: '2026-04-29T09:14:46.030Z'
updatedAt: '2026-04-29T09:19:05.531Z'
timeSpent: 0
spec: specs/specialist-dashboard
fulfills:
  - FR-5
  - FR-6
  - AC-3
---
# Actions & Navigation Integration (Integration)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kết nối các hành động bấm nút Bắt đầu và điều hướng vào màn hình Workspace. Phụ thuộc vào @task-bf8486 (UI list) và @task-q6tj9n (Frame layout).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Implement hàm startAnalysis gọi repository cập nhật Firestore status=ANALYZING
- [ ] #2 Điều hướng người dùng vào màn hình Workspace sau khi cập nhật thành công
<!-- AC:END -->

