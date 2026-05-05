---
title: 'Sample Management & Bulk Upload'
description: Specification for Sample Management UI and Bulk Image Upload functionality
createdAt: '2026-05-04T08:42:00.967Z'
updatedAt: '2026-05-04T08:46:03.903Z'
tags:
  - spec
  - approved
---

## Overview
Tính năng này cung cấp giao diện quản lý các mẫu bệnh phẩm (Samples) dành cho Lab Specialist và Manager, đồng thời tích hợp khả năng tải lên hàng loạt ảnh Metaphase sau khi quá trình nuôi cấy thành công.

## Locked Decisions
- **D1 (Standalone UI):** Quản lý mẫu là một tab riêng biệt trên thanh Side Rail. Mỗi dòng dữ liệu mẫu có nút chuyển hướng đến chi tiết Test Order/Bệnh nhân tương ứng.
- **D2 (Post-Cultivation Upload):** Chức năng Bulk Upload sẽ tự động mở Dialog sau khi Specialist chọn trạng thái "Thành công" cho mẫu.
- **D3 (Status Filtering):** Danh sách mẫu hỗ trợ bộ lọc theo các trạng thái: COLLECTED, CULTURING, HARVESTED, FAILED.

## Requirements

### Functional Requirements
- **FR-1 (Sample List):** Hiển thị danh sách tất cả các mẫu trong hệ thống với thông tin: Mã mẫu, Loại mẫu, Trạng thái, Bệnh nhân, Ngày thu nhận.
- **FR-2 (Status Update):** Cho phép Specialist chuyển trạng thái mẫu từ COLLECTED -> CULTURING -> HARVESTED (hoặc FAILED).
- **FR-3 (Bulk Upload Dialog):** Khi mẫu chuyển sang HARVESTED, hiển thị dialog cho phép chọn nhiều tệp ảnh (JPG/PNG). 
- **FR-4 (Progress Tracking):** Hiển thị tiến trình upload cho từng ảnh trong danh sách hàng loạt.
- **FR-5 (Navigation):** Nút "Xem chi tiết Order" trên mỗi dòng mẫu sẽ điều hướng người dùng đến trang Dashboard hoặc Workspace của Order đó.

### Non-Functional Requirements
- **NFR-1 (Concurrency):** Hỗ trợ upload đồng thời ít nhất 10 ảnh mà không gây lag UI.
- **NFR-2 (Real-time):** Trạng thái mẫu và danh sách ảnh phải được cập nhật tức thời qua Firestore.

## Acceptance Criteria
- [ ] **AC-1:** Click vào tab "Quản lý mẫu" hiển thị đúng danh sách mẫu của Specialist hiện tại hoặc toàn bộ mẫu (nếu là Manager).
- [ ] **AC-2:** Khi bấm "Xác nhận thành công" trên một mẫu đang nuôi cấy, Dialog chọn ảnh xuất hiện ngay lập tức.
- [ ] **AC-3:** Chọn 5 ảnh và bấm upload, hệ thống hiển thị thanh tiến trình và sau khi hoàn tất, 5 record mới xuất hiện trong sub-collection metaphase_images của Order tương ứng.
- [ ] **AC-4:** Bộ lọc trạng thái hoạt động chính xác, lọc đúng các mẫu theo yêu cầu.

## Scenarios

### Scenario 1: Specialist cập nhật mẫu và upload ảnh
**Given** Specialist đang ở trang Quản lý mẫu và có 1 mẫu ở trạng thái CULTURING.
**When** Specialist bấm "Thu hoạch thành công".
**Then** Một Dialog hiện ra, Specialist chọn 10 ảnh Metaphase từ máy tính và bấm "Tải lên".
**And** Sau khi upload xong, trạng thái mẫu chuyển thành HARVESTED và Test Order chuyển sang trạng thái ANALYZING.

### Scenario 2: Xem thông tin bệnh nhân từ danh sách mẫu
**Given** Danh sách mẫu đang hiển thị.
**When** Specialist bấm vào icon "Thông tin" cạnh tên bệnh nhân.
**Then** Hệ thống điều hướng đến trang chi tiết Test Order của bệnh nhân đó.

## Technical Notes
- Cập nhật SampleRepository để thêm các hàm watchSamples và watchSamplesByStatus.
- Sử dụng file_picker package để hỗ trợ chọn nhiều file.
- AiAnalysisCubit cần được mở rộng để xử lý uploadMultipleImages.
