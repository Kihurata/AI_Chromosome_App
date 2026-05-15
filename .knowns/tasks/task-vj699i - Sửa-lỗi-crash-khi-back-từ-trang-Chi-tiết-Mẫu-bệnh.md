---
id: vj699i
title: Sửa lỗi crash khi back từ trang Chi tiết Mẫu bệnh phẩm
status: done
priority: high
labels:
  - bug
  - navigation
createdAt: '2026-05-14T07:04:32.264Z'
updatedAt: '2026-05-14T07:08:16.454Z'
timeSpent: 219
assignee: '@me'
---
# Sửa lỗi crash khi back từ trang Chi tiết Mẫu bệnh phẩm

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nghiên cứu cho thấy lỗi xảy ra do dùng lẫn lộn GoRouter và Navigator.pop dẫn đến mất đồng bộ state. Cần cập nhật AppHeader và SampleDetailScreen để dùng GoRouter pop.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Refactor AppHeader back button logic
- [x] #2 Refactor SampleDetailScreen navigation
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Refactor AppHeader back button logic**: Cập nhật `app_header.dart` tại dòng 62 để ưu tiên dùng `context.pop()` nếu `GoRouter.of(context).canPop()` trả về true, ngược lại mới dùng `Navigator.of(context).pop()`.
2. **Refactor SampleDetailScreen navigation**: Cập nhật `sample_detail_screen.dart` tại các dòng 97 và 171 để dùng `context.pop()` thay vì `Navigator.pop(context)`.
3. **Verify**: Chạy lại ứng dụng và kiểm tra luồng điều hướng: Dashboard -> Click Row -> Chi tiết -> Bấm Back/Hủy -> Kiểm tra xem Dashboard có hoạt động bình thường không.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Refactored AppHeader and SampleDetailScreen to use GoRouter's context.pop().
<!-- SECTION:NOTES:END -->

