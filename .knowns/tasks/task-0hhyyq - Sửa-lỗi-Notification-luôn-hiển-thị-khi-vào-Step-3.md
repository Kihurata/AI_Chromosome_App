---
id: 0hhyyq
title: Sửa lỗi Notification luôn hiển thị khi vào Step 3
status: done
priority: medium
labels:
  - bug
  - workspace
createdAt: '2026-05-14T08:04:14.048Z'
updatedAt: '2026-05-14T08:12:20.033Z'
timeSpent: 482
assignee: '@me'
---
# Sửa lỗi Notification luôn hiển thị khi vào Step 3

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Khi vào Step 3, hệ thống tự động fetch dữ liệu và trả về trạng thái success, kích hoạt snackbar 'Thành công'. Cần tách biệt trạng thái fetch thành công để không hiện snackbar.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Thêm trạng thái loaded vào WorkspaceStatus thành công
- [x] #2 Cập nhật fetchChromosomesForStep3 để dùng trạng thái loaded
- [x] #3 Không hiển thị Snackbar 'Thành công' khi vào Step 3
- [x] #4 Không có lỗi compile
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Kế hoạch chi tiết (Dành cho User tự thực hiện)

Bạn sẽ là người trực tiếp sửa code. Tôi sẽ hướng dẫn từng bước và hỗ trợ kiểm tra lỗi.

### Bước 1: Thêm trạng thái `loaded` vào Enum `WorkspaceStatus`
- **File cần sửa**: `frontend/lib/logic/bloc/workspace/workspace_cubit.dart`
- **Vị trí**: Dòng 9.
- **Hành động**: Thêm `loaded` vào enum `WorkspaceStatus`.
  ```dart
  enum WorkspaceStatus { initial, loading, success, error, loaded }
  ```

### Bước 2: Cập nhật `WorkspaceCubit` để dùng trạng thái `loaded` khi fetch dữ liệu
- **File cần sửa**: `frontend/lib/logic/bloc/workspace/workspace_cubit.dart`
- **Vị trí**: Hàm `fetchChromosomesForStep3()` (khoảng dòng 106).
- **Hành động**: Đổi `status: WorkspaceStatus.success` thành `status: WorkspaceStatus.loaded`.
  ```dart
  emit(state.copyWith(
    status: WorkspaceStatus.loaded, // Sửa ở đây
    chromosomes: chromosomes,
    suggestions: suggestions,
    isDirty: false,
  ));
  ```

### Bước 3: Kiểm tra và xác nhận
- Sau khi bạn sửa xong 2 bước trên, hãy báo cho tôi biết.
- Tôi sẽ chạy lệnh `dart analyze` để kiểm tra lỗi cú pháp giúp bạn.
- Bạn có thể tải lại trang web để kiểm tra xem Notification "Thành công" đã biến mất khi vào Step 3 chưa.

---
Bạn đã sẵn sàng chưa? Hãy bắt đầu với **Bước 1** nhé!
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: User implemented the changes to add 'loaded' status and use it in fetchChromosomesForStep3. Verified with dart analyze.
<!-- SECTION:NOTES:END -->

