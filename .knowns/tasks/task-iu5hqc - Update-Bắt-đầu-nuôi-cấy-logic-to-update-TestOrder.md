---
id: iu5hqc
title: 'Update ''Bắt đầu nuôi cấy'' logic to update TestOrder status'
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-08T02:43:57.465Z'
updatedAt: '2026-05-08T02:45:34.758Z'
timeSpent: 71
spec: specs/update-sample-management-workflow
fulfills:
  - AC-1
---
# Update 'Bắt đầu nuôi cấy' logic to update TestOrder status

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Khi nhấn 'Bắt đầu nuôi cấy', cập nhật trạng thái của test_order thành CULTURING.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Cập nhật SampleCard để gọi phương thức cập nhật test_order
- [x] #2 Đảm bảo trạng thái test_order chuyển thành CULTURING
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Cap nhat SampleManagementCubit.updateStatus nhan them orderId.
2. Goi _updateOrderStatus trong updateStatus khi chuyen sang culturing hoac harvested.
3. Cap nhat sample_management_page.dart de truyen orderId vao updateStatus.
<!-- SECTION:PLAN:END -->

