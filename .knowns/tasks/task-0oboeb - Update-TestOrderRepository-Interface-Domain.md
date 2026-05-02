---
id: 0oboeb
title: Update TestOrderRepository Interface (Domain)
status: done
priority: high
labels: []
createdAt: '2026-04-29T09:26:21.109Z'
updatedAt: '2026-04-29T09:43:33.085Z'
timeSpent: 19
spec: specs/specialist-dashboard
---
# Update TestOrderRepository Interface (Domain)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Thêm watchAssignedOrders(String specialistId) vào TestOrderRepository interface.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Thêm watchAssignedOrders(String specialistId) trả về Stream<Either<Failure, List<TestOrder>>> vào TestOrderRepository interface.
- [x] #2 Thêm implement rỗng hoặc cơ bản vào TestOrderRepositoryImpl để code không bị lỗi compile.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Mở file `lib/domain/repositories/test_order_repository.dart` và thêm `Stream<Either<Failure, List<TestOrder>>> watchAssignedOrders(String specialistId);`.
2. Mở file `lib/data/repositories/test_order_repository_impl.dart` và thêm một implementation cơ bản cho `watchAssignedOrders` (trả về Stream trống hoặc throw UnimplementedError) để đảm bảo không bị lỗi build, chuẩn bị cho task tiếp theo (27iuwg).
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Added watchAssignedOrders to TestOrderRepository interface and provided a stub implementation in TestOrderRepositoryImpl. Passed dart analyze.
<!-- SECTION:NOTES:END -->

