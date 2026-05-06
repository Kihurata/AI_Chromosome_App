---
id: 2tou5t
title: Refactor Receptionist UI to Clean Architecture
status: done
priority: high
labels:
  - ui
  - refactor
  - receptionist
  - clean-architecture
createdAt: '2026-04-27T17:15:12.664Z'
updatedAt: '2026-05-01T10:26:09.272Z'
timeSpent: 0
assignee: '@me'
---
# Refactor Receptionist UI to Clean Architecture

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove all ClinicalRepository and direct cloud_firestore dependencies from the Receptionist Presentation layer. Replace with BlocBuilder/BlocListener patterns consuming AppointmentCubit. Affects 7 files across screens and widgets.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Loại bỏ hoàn toàn ClinicalRepository và các dependency Firestore trực tiếp khỏi Presentation layer.
- [x] #2 Sử dụng BlocBuilder/BlocListener để tiêu thụ dữ liệu từ AppointmentCubit và PatientCubit.
- [x] #3 Sử dụng MainListLayout/MainFormLayout để chuẩn hóa cấu trúc màn hình.
- [x] #4 Đảm bảo điều hướng không phụ thuộc vào data layer (sử dụng Navigator hoặc GoRouter).
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Kiểm tra sự tồn tại của `ClinicalRepository` và `cloud_firestore` trong thư mục `presentation/screens/receptionist` và `presentation/widgets/receptionist`.
2. Xác nhận tất cả các Widget/Screen đã chuyển sang sử dụng `BlocBuilder` và `BlocListener` kết nối với `PatientCubit`, `AppointmentCubit`.
3. Xóa code rác/comment không cần thiết (nếu có).
4. Đóng task vì cấu trúc đã đạt chuẩn Clean Architecture.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã rà soát toàn bộ thư mục `receptionist` (screens & widgets). Kết quả: không còn import trực tiếp Repository hay Firestore. Toàn bộ logic đã được chuyển sang Cubit/Bloc. Cấu trúc Layout đã được chuẩn hóa.
<!-- SECTION:NOTES:END -->

