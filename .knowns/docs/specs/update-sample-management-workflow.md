---
title: Update Sample Management Workflow
description: Specification for updating Sample Management workflow in Specialist module
createdAt: '2026-05-08T02:31:58.029Z'
updatedAt: '2026-05-08T02:31:58.029Z'
tags:
  - spec
  - approved
---

## Overview

Cập nhật quy trình Quản lý mẫu (Sample Management) của Specialist để tối ưu hóa việc chuyển đổi trạng thái từ nuôi cấy, thu hoạch sang phân tích, đồng thời loại bỏ bước upload ảnh không cần thiết ở giai đoạn thu hoạch.

## Locked Decisions

- **D1**: Khi nhấn "Bắt đầu nuôi cấy", cập nhật trạng thái của `test_order` thành `CULTURING` để đồng bộ với Dashboard.
- **D2**: Khi nhấn "Thu hoạch", loại bỏ popup upload ảnh hàng loạt và thay bằng một dialog xác nhận đơn giản. Trạng thái của `test_order` sẽ chuyển thành `ANALYZING`.
- **D3**: Nút "Bắt đầu phân tích" sẽ xuất hiện sau khi thu hoạch (khi trạng thái là `ANALYZING`) và điều hướng người dùng vào trang Workspace tương tự như nút "Tiếp tục" ở Dashboard.

## Requirements

### Functional Requirements
- **FR-1**: Khi nhấn "Bắt đầu nuôi cấy" trong `SampleCard`, ngoài việc cập nhật trạng thái `Sample` thành `culturing`, phải cập nhật trạng thái của `test_order` liên quan thành `CULTURING`.
- **FR-2**: Khi nhấn "Thu hoạch", thay thế `BulkUploadDialog` bằng một `AlertDialog` xác nhận đơn giản.
- **FR-3**: Khi xác nhận "Thu hoạch", cập nhật trạng thái `Sample` thành `harvested` và trạng thái `test_order` thành `ANALYZING`.
- **FR-4**: Hiển thị nút "Bắt đầu phân tích" cho các mẫu đã thu hoạch (hoặc orders có trạng thái `ANALYZING`).
- **FR-5**: Khi nhấn "Bắt đầu phân tích", điều hướng người dùng đến trang Workspace của `test_order` đó.

### Non-Functional Requirements
- **NFR-1**: Đảm bảo tính nhất quán dữ liệu giữa collection `samples` và `test_orders`.

## Acceptance Criteria

- [ ] **AC-1**: Nhấn "Bắt đầu nuôi cấy" -> `Sample` chuyển thành `culturing` và `test_order` chuyển thành `CULTURING`.
- [ ] **AC-2**: Nhấn "Thu hoạch" -> Hiển thị dialog xác nhận, không hiển thị popup upload ảnh.
- [ ] **AC-3**: Xác nhận Thu hoạch -> `Sample` chuyển thành `harvested` và `test_order` chuyển thành `ANALYZING`.
- [ ] **AC-4**: Nút "Bắt đầu phân tích" xuất hiện và điều hướng đúng vào trang Workspace.

## Scenarios

### Scenario 1: Bắt đầu nuôi cấy
**Given** Một mẫu ở trạng thái `collected` (MỚI).
**When** Specialist nhấn "Bắt đầu nuôi cấy" và xác nhận.
**Then** Trạng thái mẫu chuyển sang `culturing` và trạng thái TestOrder chuyển sang `CULTURING`.

### Scenario 2: Thu hoạch mẫu
**Given** Một mẫu ở trạng thái `culturing` (NUÔI CẤY).
**When** Specialist nhấn "Thu hoạch" và xác nhận trong dialog.
**Then** Trạng thái mẫu chuyển sang `harvested` và trạng thái TestOrder chuyển sang `ANALYZING`.

### Scenario 3: Bắt đầu phân tích
**Given** Một mẫu ở trạng thái `harvested` (THÀNH CÔNG).
**When** Specialist nhấn "Bắt đầu phân tích".
**Then** Hệ thống điều hướng đến màn hình Workspace của phiếu xét nghiệm tương ứng.

## Technical Notes

- Cần kiểm tra xem `SampleManagementCubit` đã có phương thức cập nhật trạng thái `test_order` chưa, nếu chưa cần bổ sung hoặc gọi `TestOrderRepository` trực tiếp nếu làm theo cách đơn giản như user yêu cầu.
- Nút "Bắt đầu phân tích" hiện tại trong `SampleCard` đang gọi `SampleManagementCubit.startAnalysis`. Cần kiểm tra logic điều hướng trong phương thức này.
