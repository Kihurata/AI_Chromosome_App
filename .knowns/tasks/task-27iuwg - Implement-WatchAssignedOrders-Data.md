---
id: 27iuwg
title: Implement WatchAssignedOrders (Data)
status: done
priority: high
labels: []
createdAt: '2026-04-29T09:26:21.407Z'
updatedAt: '2026-04-29T09:46:40.480Z'
timeSpent: 17
spec: specs/specialist-dashboard
---
# Implement WatchAssignedOrders (Data)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai logic Firestore stream query trong TestOrderRepositoryImpl.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Thêm watchAssignedOrders vào TestOrderRemoteDataSource interface và implementation.
- [x] #2 TestOrderRepositoryImpl sử dụng DataSource để trả về Stream<Either<Failure, List<TestOrder>>>.
- [x] #3 Stream xử lý mapping model sang entity và bắt lỗi trả về Left(ServerFailure).
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Cập nhật `lib/data/datasources/test_order_remote_datasource.dart`:
   - Thêm `Stream<List<TestOrderModel>> watchAssignedOrders(String specialistId);` vào interface.
   - Triển khai trong `FirebaseTestOrderRemoteDataSource` sử dụng Firestore `snapshots()` query theo `specialist_id` (document reference).
2. Cập nhật `lib/data/repositories/test_order_repository_impl.dart`:
   - Thay thế stub của `watchAssignedOrders` bằng logic thực tế.
   - Sử dụng `remoteDataSource.watchAssignedOrders(specialistId).map(...)`.
   - Bọc trong `try-catch` hoặc xử lý stream error để trả về `Left(ServerFailure)`.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Implemented watchAssignedOrders in TestOrderRemoteDataSource and TestOrderRepositoryImpl. Passed dart analyze.
<!-- SECTION:NOTES:END -->

