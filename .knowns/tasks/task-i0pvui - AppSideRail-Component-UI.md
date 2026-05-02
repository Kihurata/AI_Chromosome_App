---
id: i0pvui
title: AppSideRail Component (UI)
status: done
priority: medium
labels: []
createdAt: '2026-04-29T09:14:44.593Z'
updatedAt: '2026-04-29T09:34:09.884Z'
timeSpent: 0
spec: specs/common-layout-components
fulfills:
  - FR-1
  - FR-2
  - AC-2
---
# AppSideRail Component (UI)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng thanh điều hướng dọc với danh sách menu lọc theo Role. Phụ thuộc vào @task-f9ugr0 (quản lý trạng thái đóng/mở).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng SideRail hỗ trợ Expand/Collapse animation
- [x] #2 Lọc danh sách NavItem theo AppRole của user hiện tại
- [x] #3 Gắn sự kiện chuyển trang bằng GoRouter/AppRouter
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Create AppSideRail**: Xây dựng widget `AppSideRail` tại `lib/presentation/widgets/shared/navigation/app_side_rail.dart`.
2. **Centralized State**: Sử dụng `BlocBuilder<LayoutCubit, LayoutState>` để lắng nghe trạng thái `isSidebarCollapsed`.
3. **Role-based Navigation**: Sử dụng `ref.watch(filteredNavItemsProvider)` để lấy danh sách menu theo quyền của User.
4. **UI Details**: 
    - Hiệu ứng `AnimatedContainer` cho việc co giãn sidebar (230px \u003c-\u003e 72px).
    - Hiển thị Logo và tên ứng dụng (ẩn tên khi co lại).
    - Tích hợp nút Toggle gọi `LayoutCubit.toggleSidebar()`.
5. **Event Handling**: Gọi `context.go()` khi người dùng chọn một mục menu.

## Verification Plan
- Kiểm tra tính năng co giãn sidebar khi bấm nút Toggle.
- Kiểm tra danh sách menu thay đổi chính xác khi Login với các Role khác nhau (Receptionist, Specialist).
- Kiểm tra tính năng chuyển trang khi click menu.
<!-- SECTION:PLAN:END -->

