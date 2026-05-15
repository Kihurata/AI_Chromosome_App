---
id: 5p4l7d
title: Sửa nút Quay lại ở Step 1 và ẩn Sidebar trong Workspace
status: done
priority: medium
labels:
  - workspace
  - ui
createdAt: '2026-05-14T08:23:03.761Z'
updatedAt: '2026-05-14T09:11:41.041Z'
timeSpent: 2915
assignee: '@me'
---
# Sửa nút Quay lại ở Step 1 và ẩn Sidebar trong Workspace

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Cho phép nút Quay lại ở Step 1 hoạt động và về màn hình Quản lý mẫu. Ẩn Sidebar khi đang ở màn hình Workspace.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ẩn Sidebar thành công khi ở màn hình Workspace
- [x] #2 Nút Quay lại ở Step 1 hoạt động và về màn hình Quản lý mẫu
- [x] #3 Không có lỗi compile
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Kế hoạch chi tiết (Dành cho User tự thực hiện)

Bạn sẽ thực hiện chỉnh sửa ở 2 file. Tôi sẽ hướng dẫn chi tiết từng bước.

### Phần 1: Ẩn Sidebar trong Workspace
Chúng ta sẽ sửa file `MainShell` để ẩn sidebar khi đường dẫn là Workspace.

- **File cần sửa**: `frontend/lib/presentation/widgets/shared/navigation/main_shell.dart`
- **Bước 1.1**: Thêm các import cần thiết vào đầu file (nếu chưa có):
  ```dart
  import 'package:go_router/go_router.dart';
  import '../../../../core/router/app_router.dart';
  ```
- **Bước 1.2**: Trong hàm `build`, lấy đường dẫn hiện tại và kiểm tra xem có phải là Workspace không:
  ```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(drawerProvider);
    
    // Thêm 2 dòng này:
    final location = GoRouterState.of(context).matchedLocation;
    final isWorkspace = location.startsWith(AppRoutes.specialistAnalysis);

    return Scaffold(
      // ... giữ nguyên ...
  ```
- **Bước 1.3**: Ở phần `body: Row`, thêm điều kiện để chỉ hiển thị `AppSideRail` khi không phải Workspace:
  ```dart
        children: [
          // Sửa dòng này:
          if (!isWorkspace) const AppSideRail(),
          
          // Right: Content Area ...
  ```

---

### Phần 2: Sửa nút "Quay lại" ở Step 1
Chúng ta sẽ sửa file `WorkspaceScreen` để nút "Quay lại" hoạt động ở Step 1.

- **File cần sửa**: `frontend/lib/presentation/screens/workspace/workspace_screen.dart`
- **Bước 2.1**: Thêm import `go_router` vào đầu file (nếu chưa có):
  ```dart
  import 'package:go_router/go_router.dart';
  ```
- **Bước 2.2**: Tìm đến đoạn code hiển thị nút "Quay lại" (khoảng dòng 158) và sửa lại `onPressed`:
  ```dart
  // Tìm đoạn này:
  AppSecondaryButton(
    text: 'Quay lại',
    onPressed: state.currentStep > 1
        ? () => _handleNavigation(context, state, () => context.read<WorkspaceCubit>().previousStep())
        : null,
  ),
  
  // Sửa thành:
  AppSecondaryButton(
    text: 'Quay lại',
    onPressed: () {
      if (state.currentStep > 1) {
        _handleNavigation(context, state, () => context.read<WorkspaceCubit>().previousStep());
      } else {
        context.goNamed('specialist-samples');
      }
    },
  ),
  ```

---
### Bước 3: Kiểm tra
- Sau khi sửa xong, hãy báo cho tôi để tôi chạy `dart analyze` kiểm tra lỗi giúp bạn.

Bạn hãy bắt đầu với **Phần 1** nhé! Khá nhiều bước nên cứ thong thả làm từng file một.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: User implemented the changes to hide sidebar in Workspace and enable back button in Step 1. Verified with dart analyze.
<!-- SECTION:NOTES:END -->

