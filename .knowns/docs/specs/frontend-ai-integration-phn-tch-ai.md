---
title: Frontend AI Integration (Phân tích AI)
description: Đặc tả kết nối nút Phân tích AI trên frontend với Backend API
createdAt: '2026-05-07T06:34:52.251Z'
updatedAt: '2026-05-07T06:42:49.754Z'
tags:
  - spec
  - approved
  - frontend
  - ai-integration
---

## Overview
Tài liệu này đặc tả việc kết nối nút "Phân tích AI" trên màn hình Workspace (Bước 1: Sàng lọc) của Frontend với hệ thống phân tích AI. Hiện tại Frontend đã xử lý xong phần upload ảnh lên Firebase Storage. Tính năng này sẽ kích hoạt luồng phân tích **tất cả các ảnh** đã upload thông qua Backend, và hiển thị giao diện đối chiếu (Original vs AI) dưới dạng Popup cho người dùng duyệt lại.

## Locked Decisions
- **D1**: Frontend gọi **Backend API trung gian** để kích hoạt tiến trình AI cho tất cả ảnh của Order, thay vì gọi trực tiếp tới AI Server.
- **D2**: Thiết kế **Bất đồng bộ (Asynchronous)**: Frontend kích hoạt API, Backend xử lý ngầm và lưu vào Firestore. Frontend sẽ lắng nghe sự thay đổi trạng thái trực tiếp trên Firestore để tự động cập nhật UI.
- **D3**: Sử dụng **Loading Overlay toàn màn hình** (Full-screen blocking) trong lúc đợi AI phân tích để ngăn chặn thao tác khác.
- **D4**: **Không tự động chuyển bước**. Người dùng ở lại màn hình Bước 1 sau khi phân tích xong để xem lại kết quả từng ảnh.
- **D5 (Endpoint)**: Thiết kế API Endpoint chuẩn: `POST /api/v1/orders/{test_order_id}/analyze`.
- **D6 (AI Image)**: AI Server đã tự động upload ảnh kết quả (annotated image) lên Firebase Storage. Frontend chỉ cần đọc URL từ Firestore và hiển thị.

## Requirements

### Functional Requirements
- **FR-1**: Bắt sự kiện nhấn nút "Phân tích AI" trên `workspace_screen.dart`.
- **FR-2**: Kích hoạt hiển thị màn hình chờ toàn màn hình (Loading Overlay) kèm dòng chữ "Đang phân tích cấu trúc nhiễm sắc thể...".
- **FR-3**: Gọi HTTP Request `POST /api/v1/orders/{test_order_id}/analyze` tới Backend API để kích hoạt AI xử lý cho **toàn bộ ảnh** trong Order hiện tại.
- **FR-4**: Frontend liên tục lắng nghe document(s) của các ảnh trên Firestore để chờ trạng thái thay đổi sang `COMPLETED` hoặc `FAILED`.
- **FR-5**: Khi tất cả phân tích xong: Ẩn Loading Overlay, hiện thông báo thành công. Màn hình vẫn giữ ở "Bước 1: Sàng lọc".
- **FR-6**: Cập nhật danh sách ảnh: Mỗi ảnh lúc này có thể biểu thị trạng thái đã phân tích.
- **FR-7**: **Xem chi tiết ảnh AI**: Khi click vào một ảnh đã được phân tích, hiển thị một Popup (Dialog) đối chiếu:
  - Nửa trái: Hiển thị **Ảnh gốc** (Original).
  - Nửa phải: Hiển thị **Ảnh AI** (Load URL ảnh đã được AI xử lý từ Firestore).
  - Thông tin đi kèm: Độ tự tin (Confidence score), số lượng nhiễm sắc thể (NST) mà AI đếm được.
- **FR-8**: Khi có lỗi: Ẩn Loading Overlay và hiển thị lỗi qua SnackBar.

### Non-Functional Requirements
- **NFR-1 (Độ trễ UI)**: Overlay phải xuất hiện ngay lập tức khi nhấn nút, không có độ trễ.
- **NFR-2 (Bảo mật)**: Gọi qua Backend API giúp Frontend ẩn `X-API-Key` của AI Server.

## Acceptance Criteria
- [ ] AC-1: Nhấn "Phân tích AI" hiện lên Loading Overlay che toàn màn hình.
- [ ] AC-2: Request được gửi thành công đến Backend API `POST /api/v1/orders/{id}/analyze`.
- [ ] AC-3: Quá trình hoàn tất, Overlay biến mất, hiện thông báo thành công và KHÔNG tự chuyển sang Bước 2.
- [ ] AC-4: Bấm vào ảnh đã phân tích sẽ mở Dialog chứa 2 ảnh (Trái - Gốc, Phải - AI) và các thông số (Độ tự tin, số NST).
- [ ] AC-5: Xử lý lỗi (API chết, Backend timeout) hiển thị SnackBar đỏ.

## Scenarios

### Scenario 1: Phân tích thành công và xem lại (Happy Path)
**Given** Người dùng đang ở màn hình Sàng lọc, ảnh đã được upload thành công.
**When** Người dùng nhấn "Phân tích AI".
**Then** Màn hình bị làm mờ với hiệu ứng Loading.
**And** Khi dữ liệu Firestore báo `COMPLETED`, Loading biến mất, báo "Phân tích thành công".
**When** Người dùng click vào một bức ảnh.
**Then** Một Dialog hiện ra cho phép so sánh ảnh Gốc và ảnh AI đã đánh dấu, với dòng chữ thông tin độ tự tin, số NST.
