---
id: 7n55ph
title: Manager Dashboard Logic \u0026 Specialist Services (Logic)
status: done
priority: high
labels: []
createdAt: '2026-04-29T13:43:28.000Z'
updatedAt: '2026-04-29T18:12:58.350Z'
timeSpent: 0
spec: specs/manager-dashboard
fulfills:
  - FR-1
  - FR-3
  - FR-6
---
# Manager Dashboard Logic \u0026 Specialist Services (Logic)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai tầng Logic cho Manager bao gồm: Tính toán chỉ số thống kê toàn phòng Lab và dịch vụ Lookup danh sách Specialist.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Triển khai SpecialistLookupService (fetch users where role=specialist)
- [x] #2 Cập nhật ManagerDashboardCubit lắng nghe Stream toàn bộ TestOrders
- [x] #3 Viết logic tính toán stats cho Manager (Bento Box)
- [x] #4 Implement logic assignSpecialist, approveOrder, rejectOrder trong Cubit/Repository
<!-- AC:END -->

