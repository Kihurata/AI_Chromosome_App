---
id: 1ghsqv
title: 'Manager Data & Logic Layer Implementation'
status: done
priority: high
labels:
  - domain
  - data
  - logic
  - manager
createdAt: '2026-04-27T07:32:06.757Z'
updatedAt: '2026-04-27T07:53:54.861Z'
timeSpent: 168
---
# Manager Data & Logic Layer Implementation

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement the Domain, Data, and Logic layers for the Lab Manager role. This includes managing pending orders, assigning specialists, and approving or rejecting final Karyotype results.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Extend `TestOrderRepository` with `getAllPendingOrders`, `updateOrderStatus`, and `assignSpecialistToOrder`.
- [x] #2 Implement `SpecialistRemoteDataSource` to fetch users with the `specialist` role.
- [x] #3 Implement Usecases: `AssignOrderToSpecialist`, `ApproveKaryotypeResult`, `RejectKaryotypeResult`.
- [x] #4 Implement `ManagerDashboardCubit` to fetch and manage the list of pending/unassigned orders.
- [x] #5 Implement `ManagerApprovalCubit` to handle the approve/reject state and logic.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Extended TestOrderRemoteDataSource with getAllPendingOrders/updateOrderStatus/assignSpecialistToOrder. Extended TestOrderRepository interface + TestOrderRepositoryImpl with 3 new Manager methods. Created SpecialistRemoteDataSource (fetches users with role=specialist). Created usecases: GetAllPendingOrders, AssignOrderToSpecialist, ApproveKaryotypeResult, RejectKaryotypeResult. Created ManagerDashboardCubit + ManagerDashboardState. Created ManagerApprovalCubit + ManagerApprovalState. dart analyze: No issues found on all 12 target files.
<!-- SECTION:NOTES:END -->

