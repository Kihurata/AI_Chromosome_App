---
title: Manager Approval UI Specification
description: Specification for the Manager Approval and Report Review screen.
createdAt: '2026-05-08T07:01:33.045Z'
updatedAt: '2026-05-08T07:02:30.813Z'
tags:
  - spec
  - approved
---

## Overview

Màn hình phê duyệt kết quả dành cho Quản lý (Manager). Cho phép Quản lý kiểm tra lại nội dung báo cáo di truyền, hình ảnh Karyotype và thực hiện chỉnh sửa cuối cùng trước khi chính thức xuất báo cáo hoặc từ chối.

## Locked Decisions

- **D1**: Giao diện kế thừa từ Workspace Step 5. Quản lý có quyền chỉnh sửa trực tiếp nội dung báo cáo (Quill Editor).
- **D2**: Chỉ có 2 trạng thái kết thúc: Duyệt (COMPLETED) hoặc Từ chối (REJECTED). Không có quy trình sửa lại.
- **D3**: Điều hướng từ Manager Dashboard thông qua danh sách đơn hàng 'Chờ phê duyệt'.

## Requirements

### Functional Requirements
- **FR-1 (Load Data)**: Khi vào trang, hệ thống phải load dữ liệu từ Firestore (collection `test_orders`) bao gồm: thông tin bệnh nhân, ảnh Karyotype (`chromosomes`), ảnh Metaphase và đặc biệt là nội dung báo cáo (`report_content`).
- **FR-2 (Full View)**: Hiển thị đầy đủ Karyotype Grid và Metaphase Image để Quản lý đối soát dữ liệu.
- **FR-3 (Final Edit)**: Tích hợp Quill Editor với nội dung hiện tại để Quản lý có thể sửa lỗi chính tả hoặc bổ sung tư vấn di truyền.
- **FR-4 (Approve Action)**: Nút 'Duyệt Kết Quả' sẽ cập nhật trạng thái đơn hàng thành `COMPLETED` và lưu nội dung báo cáo cuối cùng.
- **FR-5 (Reject Action)**: Nút 'Từ chối' sẽ cập nhật trạng thái đơn hàng thành `REJECTED` và yêu cầu xác nhận trước khi đóng hồ sơ.

### Non-Functional Requirements
- **NFR-1 (Layout Consistency)**: Giao diện phải đồng bộ với Design System của ứng dụng và layout Workspace.
- **NFR-2 (Responsiveness)**: Áp dụng các mẫu Robust Layout (Wrap, Scroll) để tránh lỗi overflow trên các màn hình nhỏ hơn.

## Acceptance Criteria

- [ ] **AC-1**: Truy cập từ Manager Dashboard vào trang Chi tiết phê duyệt thành công.
- [ ] **AC-2**: Hiển thị đúng và đầy đủ nội dung báo cáo đã được Specialist soạn thảo trước đó.
- [ ] **AC-3**: Thay đổi nội dung trong Editor và nhấn 'Duyệt' phải cập nhật đúng dữ liệu lên Firestore.
- [ ] **AC-4**: Trạng thái đơn hàng phải chuyển sang 'Hoàn tất' (COMPLETED) sau khi duyệt.
- [ ] **AC-5**: Không bị lỗi RenderFlex overflow khi thay đổi kích thước cửa sổ trình duyệt.

## Scenarios

### Scenario 1: Duyệt báo cáo thành công
**Given** Một đơn hàng đang ở trạng thái 'WAITING_APPROVAL' có đầy đủ dữ liệu báo cáo.
**When** Quản lý mở trang chi tiết, sửa một câu trong phần tư vấn, và nhấn 'Duyệt Kết Quả'.
**Then** Dữ liệu mới được lưu, trạng thái chuyển sang 'COMPLETED', và quay về Dashboard.

### Scenario 2: Từ chối báo cáo
**Given** Một đơn hàng có dữ liệu sai sót nghiêm trọng.
**When** Quản lý nhấn 'Từ chối' và xác nhận trong Dialog.
**Then** Trạng thái đơn hàng chuyển sang 'REJECTED' và hồ sơ bị đóng lại.

## Technical Notes

- Sử dụng lại `KaryotypeGrid` widget và cấu trúc `ReportStep` để đảm bảo tính nhất quán.
- Cần tạo một Cubit mới (`ManagerApprovalCubit`) hoặc mở rộng `WorkspaceCubit` để xử lý logic phê duyệt/từ chối.
