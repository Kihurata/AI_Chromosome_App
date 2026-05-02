---
title: AI Integration Frontend
description: Specification for integrating AI Orchestrator Backend into Flutter Frontend.
createdAt: '2026-05-01T11:08:16.140Z'
updatedAt: '2026-05-02T06:52:48.868Z'
tags:
  - spec
  - approved
  - flutter
  - ai
---

## Overview
Triển khai việc kết nối giữa Flutter Frontend và AI Orchestrator Backend (FastAPI). Flutter đóng vai trò kích hoạt quá trình phân tích và phản hồi trạng thái thời gian thực từ Firestore, đồng thời tự động điều hướng quy trình khi có kết quả.

## Locked Decisions
- D1: Kích hoạt AI thủ công thông qua nút bấm "Bắt đầu phân tích AI" trên giao diện ảnh Metaphase.
- D2: UI Non-blocking. Trong khi AI đang xử lý, Specialist có thể tiếp tục thao tác các phần khác (ví dụ: xem thông tin bệnh nhân hoặc chuẩn bị các ảnh khác). Trạng thái xử lý được hiển thị qua indicator trên thumbnail.
- D3: Cơ chế Fallback. Cho phép người dùng chọn "Tự cắt thủ công" (sang Bước 2) nếu AI thất bại hoặc kết quả không ưng ý.
- D4: Tự động điều hướng. Ngay khi trạng thái ảnh chuyển thành `COMPLETED`, ứng dụng sẽ tự động chuyển Specialist sang **Bước 3 (NST đồ)** để bắt đầu sắp xếp.

## Requirements
### Functional Requirements
- FR-1: Triển khai nút "Run AI Analysis" tại Bước 1 (Screening) cho mỗi ảnh Metaphase.
- FR-2: Gọi API `POST /api/analyze` (Backend Orchestrator) khi nhấn nút.
- FR-3: Lắng nghe trạng thái `status` của `MetaphaseImage` từ Firestore theo thời gian thực.
- FR-4: Hiển thị trạng thái Loading Indicator và nhãn trạng thái (Analyzing...) trên thumbnail ảnh đang xử lý.
- FR-5: Thực hiện điều hướng tự động sang Bước 3 (Karyotyping) thông qua `WorkspaceCubit` khi nhận tín hiệu `COMPLETED`.
- FR-6: Hiển thị thông báo lỗi (SnackBar/Dialog) và nút "Thử lại" hoặc "Làm thủ công" nếu trạng thái là `FAILED`.

### Non-Functional Requirements
- NFR-1: Real-time update. Sử dụng Firestore snapshots để UI cập nhật ngay lập tức mà không cần refresh.
- NFR-2: Trải nghiệm người dùng. Đảm bảo việc điều hướng tự động (D4) không làm người dùng giật mình (có thể thêm thông báo nhẹ trước khi chuyển).

## Acceptance Criteria
- [ ] AC-1: Nhấn nút "Run AI" gửi request thành công tới backend (kiểm tra qua logs/Network).
- [ ] AC-2: Thumbnail ảnh hiển thị hiệu ứng loading và text "AI is analyzing...".
- [ ] AC-3: Khi Firestore cập nhật `status: COMPLETED`, ứng dụng tự động chuyển từ Bước 1 sang Bước 3.
- [ ] AC-4: Nếu AI lỗi, hệ thống cho phép người dùng vào Bước 2 để cắt ảnh thủ công.

## Scenarios
### Scenario 1: Happy Path (Manual Trigger + Auto-move)
**Given** Specialist đang ở Bước 1.
**When** Nhấn nút "Bắt đầu phân tích AI".
**Then** App hiển thị trạng thái đang xử lý. Khi xong, App tự động chuyển sang Bước 3 hiển thị các NST đã được tách.

### Scenario 2: AI Failure Fallback
**Given** AI Server trả về lỗi hoặc timeout.
**When** Status chuyển sang FAILED.
**Then** App hiển thị thông báo và nút "Tự cắt thủ công" dẫn người dùng sang Bước 2.

## Technical Notes
- Sử dụng `BlocListener` trong `WorkspaceScreen` để lắng nghe thay đổi trạng thái của ảnh đang chọn và điều khiển `WorkspaceCubit.setStep(3)`.
- Đảm bảo xử lý race condition nếu người dùng chuyển ảnh khác trong lúc AI đang chạy ảnh cũ.
