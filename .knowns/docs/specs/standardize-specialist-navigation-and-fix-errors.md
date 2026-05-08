---
title: Standardize Specialist Navigation and Fix Widget Errors
description: Spec for standardizing navigation and fixing widget errors in Specialist flow
tags: [spec, approved]
---

## Overview

Chuẩn hóa cách điều hướng từ Dashboard và Quản lý mẫu vào Workspace, đồng thời sửa các lỗi "Looking up a deactivated widget's ancestor" và "Cannot get renderObject of inactive element" xuất hiện do việc sử dụng context không an toàn trong các hàm dispose hoặc async callback.

## Locked Decisions

- **D1**: Thay thế `FocusScope.of(context).unfocus()` bằng `FocusManager.instance.primaryFocus?.unfocus()` trong hàm `dispose` của `SpecialistDashboardPage`.
- **D2**: Thêm kiểm tra `mounted` trước khi gọi `ScaffoldMessenger.of(context)` trong các listener của `screening_step.dart`.
- **D3**: Loại bỏ logic lắng nghe `lastStartedOrderId` thừa trong `SpecialistDashboardPage` để đồng bộ dùng điều hướng trực tiếp bằng GoRouter.

## Requirements

### Functional Requirements
- **FR-1**: Sửa file `specialist_dashboard_page.dart` để không gọi `context` trong `dispose`.
- **FR-2**: Sửa file `screening_step.dart` để bảo vệ các lệnh gọi `ScaffoldMessenger` bằng `if (!context.mounted) return;`.
- **FR-3**: Xóa bỏ `BlocListener` lắng nghe `lastStartedOrderId` trong `specialist_dashboard_page.dart` (dòng 106-116).

### Non-Functional Requirements
- **NFR-1**: Đảm bảo không còn lỗi đỏ (exception) ở console khi chuyển trang hoặc upload ảnh.

## Acceptance Criteria

- [ ] **AC-1**: Khi rời khỏi `SpecialistDashboardPage` (ví dụ bấm Tiếp tục để vào Workspace), không còn ném ra lỗi `Looking up a deactivated widget's ancestor is unsafe`.
- [ ] **AC-2**: Khi upload ảnh thành công hoặc thất bại trong `ScreeningStep` (Workspace), thông báo SnackBar hiển thị bình thường và không gây lỗi nếu người dùng đã rời trang.
- [ ] **AC-3**: Nút "Tiếp tục" ở Dashboard vẫn hoạt động bình thường bằng cách điều hướng trực tiếp.

## Scenarios

### Scenario 1: Rời Dashboard vào Workspace
**Given** Người dùng đang ở Specialist Dashboard.
**When** Người dùng bấm "Tiếp tục" ở một order.
**Then** Màn hình Workspace mở ra và console không có lỗi exception liên quan đến Focus hay Deactivated widget.

### Scenario 2: Upload ảnh trong Workspace
**Given** Người dùng đang ở bước Sàng lọc (ScreeningStep) và đang upload ảnh.
**When** Ảnh upload xong và Cubit phát ra trạng thái `AiAnalysisUploadCompleted`.
**Then** SnackBar hiển thị thành công. Nếu người dùng đã back ra ngoài trước đó, không có lỗi ném ra.

## Technical Notes

- Sử dụng `FocusManager.instance.primaryFocus?.unfocus()` thay cho `FocusScope.of(context).unfocus()`.
- Sử dụng `if (!context.mounted) return;` trước các lệnh gọi SnackBar.

## Open Questions

- Không có.
