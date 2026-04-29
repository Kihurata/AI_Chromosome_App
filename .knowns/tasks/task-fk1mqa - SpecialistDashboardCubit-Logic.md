---
id: fk1mqa
title: SpecialistDashboardCubit (Logic)
status: done
priority: high
labels: []
createdAt: '2026-04-29T09:14:45.248Z'
updatedAt: '2026-04-29T09:52:16.156Z'
timeSpent: 53
spec: specs/specialist-dashboard
fulfills:
  - FR-1
  - FR-2
  - FR-3
  - FR-4
  - NFR-2
---
# SpecialistDashboardCubit (Logic)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng tầng Logic để lắng nghe Stream từ Firestore, tính toán chỉ số thống kê và quản lý trạng thái Search/Filter cục bộ.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Inject WorkspaceRepository và lăng nghe Stream TestOrders
- [x] #2 Viết logic tính toán 4 chỉ số thống kê (Bento Box) trong Cubit
- [x] #3 Implement logic search (filter list local) theo keyword và status
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Định nghĩa `SpecialistStats` model (data class) để chứa 4 chỉ số thống kê.
2. Tạo `SpecialistDashboardState` (equatable) bao gồm: `status` (loading, success, error), `allOrders`, `filteredOrders`, `stats`, `searchKeyword`, `statusFilter`, và `errorMessage`.
3. Tạo `SpecialistDashboardCubit`:
   - Inject `WatchAssignedOrders` và `UpdateOrderStatus` (từ test_order_repository).
   - `loadOrders(String specialistId)`: Subscribe vào stream từ usecase. Sử dụng `await for` pattern (Critical Pattern).
   - Mỗi khi stream có data mới:
     - Tính toán `SpecialistStats` dựa trên `allOrders`.
     - Chạy logic `_applyFilters` để cập nhật `filteredOrders`.
   - `setSearchKeyword(String keyword)`: Cập nhật state và chạy `_applyFilters`.
   - `setStatusFilter(TestOrderStatus? status)`: Cập nhật state và chạy `_applyFilters`.
   - `startOrderAnalysis(String orderId)`: Gọi `updateOrderStatus` sang `ANALYZING`.
4. Đảm bảo clean-up subscription trong `close()`.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Implemented SpecialistDashboardCubit, SpecialistStats entity, and UpdateOrderStatus usecase. Aligned TestOrderStatus enum with spec. Passed dart analyze.
<!-- SECTION:NOTES:END -->

