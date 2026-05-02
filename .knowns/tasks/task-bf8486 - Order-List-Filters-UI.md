---
id: bf8486
title: 'Order List & Filters (UI)'
status: done
priority: medium
labels: []
createdAt: '2026-04-29T09:14:45.908Z'
updatedAt: '2026-04-29T13:38:26.602Z'
timeSpent: 108
spec: specs/specialist-dashboard
fulfills:
  - FR-2
  - FR-3
  - FR-4
  - AC-2
---
# Order List & Filters (UI)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng danh sách các phiếu xét nghiệm kèm theo thanh tìm kiếm và lọc. Phụ thuộc vào @task-fk1mqa.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng SearchBar và StatusFilter chips UI
- [x] #2 Hiển thị ListView/GridView các TestOrder cards với đầy đủ thông tin bệnh nhân
- [x] #3 Refactor SpecialistDashboardPage để tương thích với SpecialistDashboardCubit mới (enum-based state).
- [x] #4 Bóc tách (Extract) các thành phần UI (Stats, FilterBar, OrderList, OrderCard) ra các file riêng trong thư mục widgets.
- [x] #5 Đảm bảo logic search/filter và start analysis hoạt động đúng với logic mới của Cubit.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Phân tích `SpecialistDashboardPage` hiện tại và đối chiếu với `SpecialistDashboardCubit` mới.
2. Thực hiện bóc tách các thành phần UI:
   - Tạo `lib/presentation/screens/specialist/widgets/specialist_bento_stats.dart` từ logic `_buildBentoStats`.
   - Tạo `lib/presentation/screens/specialist/widgets/specialist_filter_bar.dart` từ logic `_buildSearchAndFilters`.
   - Tạo `lib/presentation/screens/specialist/widgets/specialist_order_list.dart` và `specialist_order_card.dart` từ logic `_buildOrderList` và `_buildOrderCard`.
3. Cập nhật `SpecialistDashboardPage` để sử dụng các widget mới và listen state theo `SpecialistDashboardStatus`.
4. Sửa lỗi gọi method trong Cubit: `initialize` -> `loadOrders`, `setSearch` -> `setSearchKeyword`, `startAnalysis` -> `startOrderAnalysis`.
5. Verify build và flow lọc dữ liệu.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Refactored SpecialistDashboardPage and extracted UI components into modular widgets. Updated Page and Widgets to use the new SpecialistDashboardCubit and Enum-based State. Fixed build errors and passed dart analyze.
<!-- SECTION:NOTES:END -->

