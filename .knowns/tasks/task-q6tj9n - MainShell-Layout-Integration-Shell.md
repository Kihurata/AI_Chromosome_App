---
id: q6tj9n
title: MainShell Layout Integration (Shell)
status: done
priority: high
labels: []
createdAt: '2026-04-29T09:14:44.918Z'
updatedAt: '2026-04-29T09:40:11.814Z'
timeSpent: 0
spec: specs/common-layout-components
fulfills:
  - AC-1
  - AC-4
---
# MainShell Layout Integration (Shell)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kết hợp Header và SideRail thành một khung chung bao quanh các màn hình. Phụ thuộc vào @task-zuhdmz và @task-i0pvui.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng MainShell kết hợp Header và SideRail sử dụng Row/Expanded
- [x] #2 Bọc toàn bộ app bằng MainShell trong AppRouter configuration
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Create MainShell**: Xây dựng widget `MainShell` tại `lib/presentation/widgets/shared/navigation/main_shell.dart`.
    - Sử dụng `Row` để chia không gian: Bên trái là `AppSideRail`, bên phải là vùng nội dung chính.
    - Vùng nội dung chính chứa `AppHeader` ở trên cùng và `child` (màn hình) ở dưới.
2. **Update AppRouter**: 
    - Cấu hình `ShellRoute` trong `lib/core/router/app_router.dart` để sử dụng `MainShell`.
    - Đảm bảo các route con được bọc đúng cách bởi Shell này.
3. **Clean Up**: Di chuyển logic từ `AppNavigationWrapper` cũ sang `MainShell` hoặc xóa bỏ nếu không còn sử dụng.

## Verification Plan
- Kiểm tra toàn bộ ứng dụng hiển thị Sidebar và Header đồng nhất.
- Kiểm tra điều hướng giữa các trang vẫn hoạt động mượt mà.
- Kiểm tra trạng thái co giãn của Sidebar được duy trì chính xác khi chuyển trang.
<!-- SECTION:PLAN:END -->

