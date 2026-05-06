---
title: Chi tiết Mẫu bệnh phẩm (Đồng bộ Sidebar Header)
description: Specification cho trang Chi tiết Mẫu bệnh phẩm được điều hướng từ trang Tổng quan Specialist
createdAt: '2026-05-06T08:41:28.409Z'
updatedAt: '2026-05-06T08:41:28.409Z'
tags:
  - spec
  - approved
---

# Chi tiết Phiếu xét nghiệm (Sample & Order Detail)

## Overview

Trang hiển thị thông tin chi tiết của một Phiếu xét nghiệm (Test Order) và mẫu bệnh phẩm tương ứng (bao gồm loại mẫu, trạng thái, thời gian lấy và ghi chú). Trang này đóng vai trò là một màn hình chi tiết (Detail View) có thể truy cập linh hoạt từ nhiều vị trí khác nhau trong luồng làm việc của Specialist.

## Locked Decisions

- **D1 (Multi-Entry Navigation):** Trang có thể được mở từ trang Tổng quan (Dashboard) hoặc trang Quản lý mẫu (Sample Management).
- **D2 (Independent Routing):** Sử dụng route độc lập (`/specialist/sample-detail/:id`) thay vì route con lồng nhau để tránh xung đột vòng đời (lifecycle) của các Cubit trang cha.
- **D3 (Overlay Navigation Strategy):** Sử dụng `context.pushNamed` thay vì `context.go` để đẩy trang chi tiết lên trên stack hiện tại. Điều này giữ cho trạng thái của trang Dashboard/Quản lý mẫu không bị reset khi người dùng quay lại.
- **D4 (Data Fetching):** Dữ liệu được fetch dựa trên `test_order_id`. Hệ thống sẽ tìm mẫu bệnh phẩm (Sample) liên kết với ID phiếu xét nghiệm này.

## Requirements

### Functional Requirements
- **FR-1:** Giao diện tích hợp `AppBar` với nút quay lại (Back button) để người dùng thoát khỏi chế độ xem chi tiết mà không làm mất vị trí hiện tại ở trang danh sách.
- **FR-2:** Tự động nạp dữ liệu mẫu bệnh phẩm khi ID được truyền qua route.
- **FR-3:** Hiển thị thông tin: Loại mẫu, Thời gian lấy, Trạng thái mẫu hiện tại.
- **FR-4:** Cho phép chỉnh sửa và lưu ghi chú (`notes`) của mẫu bệnh phẩm xuống Firestore.

### Non-Functional Requirements
- **NFR-1 (Stability):** Cubit (`SampleDetailCubit`) phải có cơ chế kiểm tra `isClosed` trước khi emit state để tránh lỗi crash khi người dùng thoát trang nhanh trong lúc dữ liệu đang nạp.
- **NFR-2 (Layout):** Nội dung trang phải được bọc trong `SingleChildScrollView` để đảm bảo không bị lỗi tràn khung (`RenderFlex overflow`) trên các thiết bị có chiều cao hạn chế.

## Acceptance Criteria

- [x] **AC-1:** Khi click vào một dòng ở trang Tổng quan Specialist, app mở trang chi tiết dạng overlay (vẫn thấy Sidebar).
- [x] **AC-2:** Khi click vào nút Back hoặc icon quay lại trên AppBar, người dùng quay về đúng vị trí cũ ở Dashboard/Quản lý mẫu.
- [x] **AC-3:** Thông tin mẫu hiển thị chính xác và đồng bộ với ID phiếu xét nghiệm đã chọn.
- [x] **AC-4:** Lưu ghi chú thành công và có thông báo Snackbar xác nhận.

## Scenarios

### Scenario 1: Điều hướng từ Dashboard
**Given** Specialist đang xem danh sách phiếu ở Dashboard.
**When** Specialist click vào một card phiếu xét nghiệm.
**Then** Trang chi tiết hiện lên. Khi bấm Back, Specialist quay lại Dashboard và danh sách phiếu vẫn giữ nguyên trạng thái scroll cũ.

### Scenario 2: Điều hướng từ Quản lý mẫu
**Given** Specialist đang ở trang Quản lý mẫu bệnh phẩm.
**When** Specialist click vào một dòng (row) hoặc icon "Thông tin".
**Then** Trang chi tiết hiện lên. Khi bấm Back, Specialist quay lại trang Quản lý mẫu.

## Technical Notes

- Route: `AppRoutes.specialistSampleDetail` (`/specialist/sample-detail/:id`).
- Cubit: `SampleDetailCubit` (được đăng ký dạng `factory` trong DI để reset state mỗi lần mở).
- Navigation: `context.pushNamed('specialist-sample-detail', pathParameters: {'id': order.id})`.
