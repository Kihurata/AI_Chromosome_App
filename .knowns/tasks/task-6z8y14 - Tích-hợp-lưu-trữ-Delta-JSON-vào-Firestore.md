---
id: 6z8y14
title: Tích hợp lưu trữ Delta JSON vào Firestore
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-08T04:56:13.985Z'
updatedAt: '2026-05-08T05:03:48.871Z'
timeSpent: 160
spec: specs/final-report-spec
fulfills:
  - AC-3
---
# Tích hợp lưu trữ Delta JSON vào Firestore

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lưu trữ và lấy dữ liệu Delta JSON từ Firestore cho TestOrder hiện tại.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Cập nhật Data Model để hỗ trợ trường nội dung báo cáo (Delta JSON).
- [x] #2 Lưu dữ liệu khi nhấn Lưu hoặc khi hoàn thành.
- [x] #3 Lấy dữ liệu cũ nếu có khi mở màn hình.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Cập nhật Data Model để hỗ trợ trường report_content (Delta JSON).
2. Cập nhật WorkspaceCubit để lưu report_content khi submit.
3. Cập nhật report_step.dart để đọc/ghi dữ liệu từ Cubit.
<!-- SECTION:PLAN:END -->

