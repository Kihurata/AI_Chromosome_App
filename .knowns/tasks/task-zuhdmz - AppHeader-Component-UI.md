---
id: zuhdmz
title: AppHeader Component (UI)
status: done
priority: medium
labels: []
createdAt: '2026-04-29T09:14:44.074Z'
updatedAt: '2026-04-29T09:36:11.495Z'
timeSpent: 0
spec: specs/common-layout-components
fulfills:
  - FR-3
  - FR-4
  - FR-5
  - AC-3
---
# AppHeader Component (UI)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng Widget AppHeader hiển thị Breadcrumbs, thông tin User và chuông thông báo. Phụ thuộc vào @task-f9ugr0 (để toggle sidebar/breadcrumbs logic).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng UI AppHeader với Breadcrumbs tự động
- [x] #2 Hiển thị thông tin User và nút Logout
- [x] #3 Hiển thị Notifications icon với Badge
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Refactor AppHeader**: Cập nhật `lib/presentation/widgets/shared/navigation/app_header.dart` thành một `ConsumerWidget`.
2. **Breadcrumbs Logic**: 
    - Lấy current path từ `GoRouter`.
    - Ánh xạ các segment của path sang tên tiếng Việt (VD: `receptionist` -\u003e `Tiếp nhận`, `patients` -\u003e `Bệnh nhân`).
    - Hiển thị danh sách breadcrumbs có thể click được.
3. **User Profile \u0026 Logout**:
    - Lấy thông tin `displayName` và `role` từ `authNotifierProvider`.
    - Hiển thị Avatar (initials).
    - Tích hợp nút Logout gọi action logout từ `AuthCubit`.
4. **Notifications**: Hiển thị icon chuông với Badge đỏ cho thông báo mới.

## Verification Plan
- Kiểm tra Breadcrumbs thay đổi chính xác khi chuyển giữa các Route (VD: `/receptionist/patients` và `/receptionist/patients/detail`).
- Kiểm tra thông tin User hiển thị đúng theo tài khoản đang đăng nhập.
- Kiểm tra tính năng Logout chuyển người dùng về trang Login.
<!-- SECTION:PLAN:END -->

