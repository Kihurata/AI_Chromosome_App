---
id: czqb0h
title: Xây dựng Widget hiển thị Karyotype theo chuẩn y tế
status: done
priority: medium
labels: []
createdAt: '2026-05-08T05:26:59.403Z'
updatedAt: '2026-05-08T05:33:00.826Z'
timeSpent: 0
spec: specs/karyotype-display-on-report
---
# Xây dựng Widget hiển thị Karyotype theo chuẩn y tế

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tạo widget KaryotypeGrid chia thành 4 hàng và tích hợp vào phần Preview của báo cáo.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tạo Widget KaryotypeGrid với 4 hàng cố định
- [x] #2 Tích hợp KaryotypeGrid vào report_step.dart
- [x] #3 Hiển thị đúng vị trí dưới ISCN và trên Mô tả chi tiết
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tạo Widget KaryotypeGrid trong file mới hoặc trong report_step.dart
2. Cập nhật phần Preview trong report_step.dart để chèn KaryotypeGrid vào giữa
3. Xác minh hiển thị với dữ liệu mẫu
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
📚 Extracted to @doc/learnings/learning-final-report-and-quill-integration
<!-- SECTION:NOTES:END -->

