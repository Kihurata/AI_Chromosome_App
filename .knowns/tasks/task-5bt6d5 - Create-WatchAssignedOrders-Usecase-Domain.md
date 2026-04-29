---
id: 5bt6d5
title: Create WatchAssignedOrders Usecase (Domain)
status: done
priority: high
labels: []
createdAt: '2026-04-29T09:26:21.531Z'
updatedAt: '2026-04-29T09:44:50.037Z'
timeSpent: 7
spec: specs/specialist-dashboard
---
# Create WatchAssignedOrders Usecase (Domain)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tạo WatchAssignedOrders usecase.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tạo class WatchAssignedOrders trong lib/domain/usecases/specialist/.
- [x] #2 Method call nhận specialistId và gọi TestOrderRepository.watchAssignedOrders.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tạo file `lib/domain/usecases/specialist/watch_assigned_orders.dart`.
2. Khai báo class `WatchAssignedOrders` với dependency `TestOrderRepository`.
3. Implement method `call(String specialistId)` trả về `Stream<Either<Failure, List<TestOrder>>>` bằng cách gọi repository.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Created WatchAssignedOrders usecase and passed dart analyze.
<!-- SECTION:NOTES:END -->

