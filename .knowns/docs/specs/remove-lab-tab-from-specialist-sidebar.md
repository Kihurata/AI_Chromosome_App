---
title: Remove Lab Tab from Specialist Sidebar
description: Spec for removing the "Phòng Lab AI" tab from the Specialist sidebar
tags: [spec, approved]
---

## Overview

Người dùng muốn xóa tab "Phòng Lab AI" khỏi Sidebar của Specialist. Hiện tại tab này đang được định nghĩa trong cấu hình điều hướng chung và có thể cả ở file Sidebar cứng.

## Locked Decisions

(Bỏ qua bước thảo luận vì đây là yêu cầu cụ thể và đơn giản)

## Requirements

### Functional Requirements
- **FR-1**: Xóa mục "Phòng Lab AI" khỏi danh sách `appNavItems` trong file `app_nav_items.dart`.
- **FR-2**: Xóa mục "Phòng Lab AI" khỏi danh sách hardcoded trong `app_sidebar.dart` (nếu file này vẫn đang được sử dụng).

### Non-Functional Requirements
- Không làm ảnh hưởng đến các chức năng khác hoặc gây lỗi crash app.

## Acceptance Criteria

- [ ] AC-1: Tab "Phòng Lab AI" không còn xuất hiện trên Sidebar của Specialist.
- [ ] AC-2: Ứng dụng vẫn hoạt động bình thường, không có lỗi phân tích (analyze) hay runtime.

## Scenarios

### Scenario 1: Kiểm tra Sidebar sau khi xóa
**Given** Chuyên viên (Specialist) đã đăng nhập
**When** Xem Sidebar
**Then** Không nhìn thấy mục "Phòng Lab AI"

## Technical Notes

- File cần sửa:
    - `lib/core/config/app_nav_items.dart`
    - `lib/presentation/widgets/shared/navigation/app_sidebar.dart`

## Open Questions

- Có cần xóa luôn file view/page liên quan đến `/clinician/lab` không? (Tạm thời giữ lại route và page, chỉ ẩn tab).
