---
title: Bước 1 Sàng lọc (Workspace)
description: Đặc tả giao diện và luồng tương tác cho Bước 1 Sàng lọc trong quy trình Workspace
tags:
  - spec
  - draft
  - specialist
  - ui
---

## Overview

Đặc tả giao diện và luồng tương tác cho **Bước 1: Sàng lọc (Screening)** trong quy trình Workspace của Lab Specialist. Màn hình này cho phép chuyên viên xem trước các ảnh Metaphase đã được AI đánh giá sơ bộ và chọn ra từ 1 đến 3 ảnh chất lượng tốt nhất để tiến hành bóc tách ở Bước 2.

Màn hình này được nhúng bên trong cấu trúc layout chuẩn của ứng dụng (MainShell) bao gồm AppHeader và AppSideRail đã được đồng bộ.

## Locked Decisions

- **D1:** Tương tác chọn ảnh: Người dùng click trực tiếp vào Card ảnh. Trạng thái "Đã chọn" được thể hiện qua viền nổi bật (border highlight) và icon check ở góc.
- **D2:** Hiển thị AI: Mỗi thẻ ảnh sẽ có một nhãn (badge) hiển thị điểm số chất lượng do AI đánh giá (Score từ 0-100).
- **D3:** Ràng buộc chọn ảnh: Cho phép chọn tối đa 3 ảnh. Khi đã chọn đủ 3 ảnh, các ảnh còn lại sẽ không thể click để chọn thêm. Nút "Tiếp tục" bị vô hiệu hóa (disabled) nếu số lượng ảnh chọn là 0.
- **D4:** Layout tích hợp: Sử dụng lại hoàn toàn AppHeader và AppSideRail từ MainShell, không phát triển riêng cho bước này.

## Requirements

### Functional Requirements
- **FR-1:** Hiển thị danh sách ảnh (Grid View): Hiển thị dạng lưới bộ ảnh Metaphase (5-10 ảnh) thuộc về `TestOrder` hiện tại.
- **FR-2:** Thông tin trên mỗi ảnh: Hiển thị ảnh thu nhỏ, tên file (nếu có), và Điểm chất lượng AI (AI Score).
- **FR-3:** Cơ chế lựa chọn đa nhiệm (Multi-select): Hỗ trợ click chọn / bỏ chọn từng ảnh.
- **FR-4:** Validation số lượng: Chỉ kích hoạt nút "Tiếp tục" khi `0 < số ảnh đã chọn <= 3`.
- **FR-5:** Thanh công cụ Action: Cung cấp nút "Hủy/Quay lại" và nút "Tiếp tục (Bước 2)".

### Non-Functional Requirements
- **NFR-1 (Responsive):** Grid view phải tự động co giãn số lượng cột dựa trên chiều rộng màn hình (phù hợp với màn hình Tablet/Desktop của Specialist).
- **NFR-2 (Performance):** Sử dụng `CachedNetworkImage` (hoặc tương đương) để load mượt mà các ảnh từ Firebase Storage, tránh giật lag khi cuộn.
- **NFR-3 (UX/UI):** Trạng thái chọn ảnh phải có hiệu ứng feedback rõ ràng (đổi màu viền, pop-up icon) để tránh nhầm lẫn.

## Acceptance Criteria

- [ ] **AC-1:** Khi load màn hình, danh sách ảnh Metaphase của TestOrder được hiển thị đầy đủ trong dạng lưới.
- [ ] **AC-2:** Mỗi ảnh hiển thị rõ ràng điểm AI (ví dụ: AI: 85/100).
- [ ] **AC-3:** Click vào một ảnh chưa chọn sẽ làm nổi bật ảnh đó (chọn). Click lại sẽ bỏ chọn.
- [ ] **AC-4:** Khi chưa chọn ảnh nào, nút "Tiếp tục" ở trạng thái disabled.
- [ ] **AC-5:** Khi chọn 1, 2, hoặc 3 ảnh, nút "Tiếp tục" được enable.
- [ ] **AC-6:** Khi đã chọn đúng 3 ảnh, các ảnh chưa được chọn sẽ bị vô hiệu hóa click (không thể chọn thêm ảnh thứ 4).
- [ ] **AC-7:** Bấm "Tiếp tục" sẽ lưu mảng ID các ảnh đã chọn vào State (WorkspaceCubit) và điều hướng sang Bước 2 (Slicing).
- [ ] **AC-8:** Giao diện được bao bọc đúng trong MainShell với Sidebar và Header hiển thị chính xác thông tin User/Order hiện tại.

## Scenarios

### Scenario 1: Chọn đủ ảnh hợp lệ và đi tiếp
**Given** Specialist đang ở Bước 1 và có 5 ảnh hiển thị.
**When** Specialist click chọn ảnh A và ảnh B.
**Then** Ảnh A và B hiển thị viền nổi bật. Nút "Tiếp tục" sáng lên.
**When** Specialist bấm "Tiếp tục".
**Then** Hệ thống ghi nhận ảnh A và B, màn hình chuyển sang Bước 2.

### Scenario 2: Cố gắng chọn quá giới hạn
**Given** Specialist đã chọn ảnh A, B, C (tổng = 3).
**When** Specialist click vào ảnh D.
**Then** Ảnh D không thay đổi trạng thái (vẫn là không chọn), có thể kèm hiệu ứng rung nhẹ báo lỗi. Số lượng chọn vẫn là 3.

### Scenario 3: Cố gắng đi tiếp khi chưa chọn ảnh
**Given** Specialist chưa click chọn bất kỳ ảnh nào.
**When** Specialist cố gắng bấm nút "Tiếp tục".
**Then** Không có phản hồi (vì nút đang bị disabled).

## Technical Notes

- Sử dụng `WorkspaceCubit` hiện tại để lưu trữ `List<String> selectedImageIds`.
- Sử dụng widget `GridView.builder` kết hợp với `SliverGridDelegateWithFixedCrossAxisCount` hoặc `SliverGridDelegateWithMaxCrossAxisExtent` cho tính tương thích màn hình lớn.
- Dữ liệu ảnh sẽ được lấy từ `TestOrder.metaphaseImages`.
- Thiết kế UI cần tuân thủ Design Tokens từ `ui-design-system` (patterns).

## Open Questions

- [ ] Khi chuyển sang Bước 2, Backend có cần tải trước (preload) các ảnh độ phân giải cao của những ảnh đã chọn không, hay Frontend tự fetch trực tiếp từ Storage URL?
