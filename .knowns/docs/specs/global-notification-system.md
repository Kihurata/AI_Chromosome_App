---
title: approved
description: Specification for NotificationFactory and Global Connectivity handling
createdAt: '2026-05-04T08:19:16.933Z'
updatedAt: '2026-05-04T08:21:38.785Z'
tags:
  - spec
  - draft
---

## Overview
Thiết lập hệ thống thông báo tập trung cho toàn bộ ứng dụng, sử dụng NotificationFactory Design Pattern để chuẩn hóa UI/UX và cơ chế Global Connectivity Listener để xử lý lỗi mất kết nối thời gian thực.

## Locked Decisions
- **D1 (Varieties):** Kết hợp Snackbars cho thông báo không chặn (non-blocking) và AlertDialogs cho các lỗi nghiêm trọng hoặc yêu cầu thử lại (blocking/retry).
- **D2 (Invocation):** Kích hoạt từ Presentation layer thông qua BLoC/Cubit State. Logic layer gửi kèm Type để Factory quyết định cách hiển thị.
- **D3 (Business Logic Errors):** Sử dụng Explicit Type (Enum) như `SUCCESS`, `INFO`, `WARNING`, `ERROR_RETRY`, `VALIDATION_ERROR` để điều phối UI.
- **D4 (Infrastructure Errors):** Sử dụng Global Connectivity Listener (theo dõi realtime) để hiển thị Top Banner khi mất mạng, đảm bảo an toàn cho dữ liệu Auto-save.

## Requirements

### Functional Requirements
- **FR-1 (NotificationFactory):** Phải cung cấp các phương thức tĩnh hoặc Singleton để tạo nhanh các loại thông báo dựa trên Enum.
- **FR-2 (Connectivity Service):** Tự động phát hiện trạng thái mạng (Wifi/Cellular/None) và cập nhật UI ngay lập tức mà không cần hành động từ người dùng.
- **FR-3 (Context Handling):** Hỗ trợ hiển thị thông báo có context (Snackbars gắn với Scaffold) và không context (nếu cấu hình GlobalKey).
- **FR-4 (Login Feedback):** Sửa lỗi Login hiện tại:
  - Nếu mất mạng: Hiện thông báo No Internet rõ ràng.
  - Nếu sai tài khoản: Hiện thông báo lỗi cụ thể (ví dụ: 'Email không tồn tại') thay vì lỗi chung chung.

### Non-Functional Requirements
- **NFR-1 (UI Smoothness):** Thông báo phải có hiệu ứng transition mượt mà (Fade/Slide), không gây giật lag UI chính.
- **NFR-2 (Consistency):** Màu sắc và icon phải tuân thủ đúng Design System (Blue cho Info, Red cho Error, Yellow cho Warning, Green cho Success).

## Acceptance Criteria
- [ ] **AC-1:** Tạo class `NotificationFactory` với đầy đủ các phương thức render cho 5 loại Enum đã định nghĩa.
- [ ] **AC-2:** Triển khai `ConnectivityService` sử dụng `connectivity_plus`.
- [ ] **AC-3:** Khi ngắt mạng máy tính/thiết bị, một Banner màu đỏ xuất hiện ở đầu ứng dụng báo 'Mất kết nối'. Khi có mạng lại, banner tự biến mất.
- [ ] **AC-4:** Màn hình Login hiển thị Snackbar đỏ khi nhập sai mật khẩu và hiện Dialog khi gặp lỗi server (500).
- [ ] **AC-5:** Các bước trong Workspace (Bước 3 - Kéo thả) phải hiển thị cảnh báo nếu dữ liệu không thể auto-save do mất mạng.

## Scenarios

### Scenario 1: Mất mạng khi đang làm việc (Bước 3)
**Given** Specialist đang ở Bước 3 và đang kéo thả nhiễm sắc thể.
**When** Kết nối internet bị ngắt.
**Then** Một Banner thông báo xuất hiện phía trên cùng: 'Mất kết nối. Các thao tác sẽ được lưu tạm.'. Các request auto-save bị tạm dừng hoặc lưu vào queue.

### Scenario 2: Đăng nhập sai thông tin
**Given** Người dùng nhập sai Email hoặc mật khẩu.
**When** Bấm nút 'Đăng nhập'.
**Then** Cubit nhận lỗi từ Firebase, bắn ra State kèm type `VALIDATION_ERROR`. Factory hiển thị Snackbar màu đỏ với nội dung lỗi cụ thể.

## Technical Notes
- Sử dụng `flutter_bloc` để lắng nghe trạng thái Connectivity ở tầng cao nhất (MainShell).
- `NotificationFactory` nên trả về các `Widget` hoặc gọi trực tiếp `ScaffoldMessenger`.
- Cần lưu ý việc dọn dẹp (dispose) listener mạng để tránh memory leak.
