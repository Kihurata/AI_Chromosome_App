---
id: 1tblne
title: 'Update ''Thu hoạch'' logic (remove popup, add confirmation, update TestOrder status)'
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-08T02:44:02.404Z'
updatedAt: '2026-05-08T02:46:34.151Z'
timeSpent: 48
spec: specs/update-sample-management-workflow
fulfills:
  - AC-2
  - AC-3
---
# Update 'Thu hoạch' logic (remove popup, add confirmation, update TestOrder status)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Khi nhấn 'Thu hoạch', thay popup bằng dialog xác nhận và cập nhật trạng thái test_order thành ANALYZING.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xóa popup BulkUploadDialog trong SampleCard
- [x] #2 Thêm dialog xác nhận đơn giản
- [x] #3 Cập nhật trạng thái test_order thành ANALYZING khi xác nhận
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Thay the _openBulkUpload bang _confirmHarvest trong build. 2. Them phuong thuc _confirmHarvest. 3. Xoa phuong thuc _openBulkUpload.
<!-- SECTION:PLAN:END -->

