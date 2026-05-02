---
id: f9ugr0
title: Layout State Management (Logic)
status: done
priority: medium
labels: []
createdAt: '2026-04-29T09:14:43.748Z'
updatedAt: '2026-04-29T18:06:22.473Z'
timeSpent: 0
assignee: '@me'
spec: specs/common-layout-components
fulfills:
  - FR-2
  - NFR-3
---
# Layout State Management (Logic)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai LayoutCubit để quản lý trạng thái đóng/mở của Sidebar và các thông tin UI chung khác.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tạo LayoutCubit và LayoutState (isSidebarCollapsed)
- [x] #2 Thêm phương thức toggleSidebar
- [x] #3 Đăng ký vào injection.dart và chạy build_runner
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Create Layout State**: Tạo `lib/logic/bloc/layout/layout_state.dart` định nghĩa `isSidebarCollapsed`.
2. **Create Layout Cubit**: Triển khai `LayoutCubit` trong `lib/logic/bloc/layout/layout_cubit.dart` với phương thức `toggleSidebar()`.
3. **DI Registration**: Sử dụng `@lazySingleton` cho `LayoutCubit` để duy trì trạng thái Sidebar xuyên suốt phiên làm việc.
4. **Update DI**: Chạy `flutter pub run build_runner build` để cập nhật `injection.config.dart`.

## Verification Plan
- Chạy `dart analyze` để đảm bảo không có lỗi syntax.
- Kiểm tra `injection.config.dart` xem `LayoutCubit` đã được đăng ký chưa.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Starting implementation of LayoutCubit and LayoutState.
<!-- SECTION:NOTES:END -->

