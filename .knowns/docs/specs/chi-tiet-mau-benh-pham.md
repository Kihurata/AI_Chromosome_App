---
title: "Chi tiết Mẫu bệnh phẩm (Đồng bộ Sidebar Header)"
description: "Specification cho trang Chi tiết Mẫu bệnh phẩm được điều hướng từ trang Tổng quan Specialist"
tags:
  - spec
  - approved
---

## Overview

Trang hiển thị thông tin chi tiết của một mẫu bệnh phẩm cụ thể (bao gồm loại mẫu, thời gian lấy, thời gian xử lý dự kiến và chất lượng mẫu), đồng thời cung cấp khả năng chỉnh sửa ghi chú của mẫu. Trang này được truy cập bằng cách click vào một dòng (row) trên trang Tổng quan của Specialist.

## Locked Decisions

Các quyết định đã được chốt trong quá trình khám phá (Phase 0):
- **D1 (Sidebar Header Sync):** Trang bắt buộc sử dụng lại (kế thừa) component `AppSideRail` và `AppHeader` chung từ `MainShell` layout để đảm bảo đồng bộ trạng thái hiển thị.
- **D2 (Data Fetch Strategy):** Dữ liệu mẫu bệnh phẩm sẽ được fetch 1 lần (One-time read) khi mở trang, không sử dụng lắng nghe real-time (watch) để tối ưu tài nguyên.
- **D3 (Note Editing & Navigation):** Bất kỳ user nào có quyền truy cập trang này đều có quyền chỉnh sửa ghi chú. Trang đóng vai trò là một Detail View được điều hướng từ Specialist Overview.

## Requirements

### Functional Requirements
- **FR-1:** Giao diện phải nằm trong `MainShell` layout, hiển thị chính xác Sidebar và Header mà không bị gián đoạn hay tải lại toàn bộ layout.
- **FR-2:** Hệ thống phải nhận ID của mẫu bệnh phẩm từ Route tham số (nút click từ Specialist Overview) và gọi Data layer để fetch dữ liệu mẫu.
- **FR-3:** Trang hiển thị các khối thông tin cơ bản:
  - Loại mẫu (vd: Máu ngoại vi)
  - Ngày giờ lấy mẫu
  - Thời gian dự kiến (vd: 3 ngày)
  - Mô tả chất lượng mẫu (vd: Mẫu đạt chất lượng cao).
- **FR-4:** Khối "Ghi chú mẫu bệnh phẩm" phải là một TextField (hoặc TextArea) đi kèm một nút "Lưu" (Save). Dữ liệu chỉ được cập nhật vào Firestore khi người dùng bấm nút này.

### Non-Functional Requirements
- **NFR-1:** Tuân thủ nghiêm ngặt **Clean Architecture**. Tuyệt đối không import `cloud_firestore` hay các repository vào trong tầng UI (Presentation).
- **NFR-2:** Import các thành phần giao diện cần tuân thủ cấu trúc relative path cẩn thận, tránh lỗi depth import đã được cảnh báo trong `critical-patterns`.

## Acceptance Criteria

- [ ] **AC-1:** Khi click vào một dòng ở trang Tổng quan Specialist, app chuyển hướng mượt mà sang trang Chi tiết, Sidebar và Header giữ nguyên trạng thái không bị giật/chớp.
- [ ] **AC-2:** Giao diện hiển thị đầy đủ và chính xác thông tin mẫu bệnh phẩm tương ứng với ID đã click.
- [ ] **AC-3:** User có thể nhập nội dung mới vào phần "Ghi chú mẫu bệnh phẩm" và dữ liệu này được lưu thành công xuống Firestore thông qua Cubit/Usecase.

## Scenarios

### Scenario 1: Xem chi tiết mẫu bệnh phẩm thành công (Happy Path)
**Given** User đang ở trang Tổng quan Specialist (Specialist Overview)
**When** User click vào một dòng mẫu bệnh phẩm bất kỳ
**Then** Hệ thống điều hướng sang route chi tiết, gọi API/fetch dữ liệu thành công và hiển thị các thông tin: Loại mẫu, thời gian, chất lượng, và nội dung ghi chú hiện tại.

### Scenario 2: Chỉnh sửa ghi chú (Happy Path)
**Given** User đang ở trang Chi tiết mẫu bệnh phẩm
**When** User nhập text mới vào trường "Ghi chú mẫu bệnh phẩm" và tiến hành lưu
**Then** Nội dung ghi chú mới được cập nhật xuống Firestore và hiển thị thông báo (Snackbar) cập nhật thành công.

### Scenario 3: Lỗi tải dữ liệu (Edge Case)
**Given** User điều hướng vào trang Chi tiết với ID không tồn tại (hoặc lỗi mạng)
**When** Hệ thống cố gắng fetch dữ liệu
**Then** UI hiển thị trạng thái lỗi rành mạch (vd: "Không thể tải thông tin mẫu") kèm nút "Quay lại" hoặc "Thử lại".

## Technical Notes

- Cần cập nhật Route Guard hoặc cấu hình GoRouter (nếu dùng) để bọc trang này bên trong `ShellRoute` (hoặc cấu trúc tương đương của `MainShell`) nhằm giữ nguyên `AppSideRail` và `AppHeader`.
- Trong tầng Data, tạo một phương thức `getSampleById(String id)` kiểu `Future<Sample>` (không dùng `Stream`).


