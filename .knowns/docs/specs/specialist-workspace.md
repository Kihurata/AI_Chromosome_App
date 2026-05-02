---
title: Specialist Workspace
description: Specification for Specialist Workspace (Analysis flow)
createdAt: '2026-04-29T14:46:07.854Z'
updatedAt: '2026-04-29T15:00:08.719Z'
tags:
  - spec
  - approved
---

## Overview
Thiết kế và triển khai màn hình **Workspace (Khu vực Phân tích)** dành cho Specialist. Đây là giao diện làm việc chính yếu nơi chuyên viên thực hiện quy trình 5 bước để tạo ra bảng Karyotype (NST đồ) cuối cùng và lập báo cáo chẩn đoán, kết hợp sức mạnh của AI và các công cụ thao tác thủ công.

## Locked Decisions
- **D1 (Linear Navigation):** Quy trình điều hướng là tuyến tính (bắt buộc hoàn thành bước trước mới được qua bước sau), nhưng cho phép Specialist quay lại các bước trước đó để chỉnh sửa nếu cần.
- **D2 (Hybrid Data Persistence):** Áp dụng chiến thuật Hybrid cho việc lưu dữ liệu:
  - Ở Bước 2 (Cắt/Dán): Dùng Local State cho thao tác thoải mái, chỉ đẩy lên Firestore khi bấm "Xác nhận".
  - Ở Bước 3 (Kéo thả): Dùng Optimistic UI kết hợp Auto-save có Debouncing (1-2s) sau khi thả NST để tối ưu trải nghiệm.
- **D3 (Asynchronous AI Queue):** Cơ chế "Fire and Forget" khi gọi AI. UI không block. App nhận `task_id` và trạng thái PROCESSING, hiển thị tiến độ (Lottie/Progress bar) trực tiếp ngoài màn hình Danh sách Test Orders. Khi AI hoàn tất, Firestore đẩy tín hiệu Real-time kèm Push Notification/Badge báo cho bác sĩ quay lại.
- **D4 (Image Slicing & Caching Architecture):** Giải pháp xử lý bộ nhớ tối ưu. Khi thao tác cắt ảnh (Bước 2), Flutter chỉ lưu Toạ độ (Bounding Box/Polygon) dạng Vector vào Firestore. Khi "Xác nhận", FastAPI sẽ nhận toạ độ, crop ảnh gốc thành 46 ảnh mảnh (PNG trong suốt), đẩy lên Storage và trả URL về cho Flutter. Bước 3 sử dụng `Image.network(url)` để tận dụng OS Caching, triệt tiêu nguy cơ quá tải RAM.

## Requirements

### Functional Requirements
- **FR-1 (Bước 1: Sàng lọc):** Hiển thị bộ ảnh Metaphase (5-10 ảnh) đã được AI đánh giá sơ bộ. Cho phép Specialist chọn ra các ảnh rõ nét, đủ tiêu chuẩn nhất để đưa vào xử lý.
- **FR-2 (Bước 2: Phân loại - Tách NST):** Hiển thị các cụm NST đã được AI tự động bóc tách. Cung cấp bộ công cụ drawing (khoanh vùng lasso, crop, dán) để Specialist can thiệp thủ công tách các cụm NST dính nhau mà AI xử lý chưa tốt.
- **FR-3 (Bước 3: Lập NST đồ):** Cung cấp giao diện kéo thả (Drag & Drop) để Specialist di chuyển các NST riêng lẻ và xếp thành từng cặp tương đồng (1-22, X/Y) trên lưới Karyotype chuẩn.
- **FR-4 (Bước 4: Phê duyệt QC / Chẩn đoán):** Cung cấp giao diện để Specialist nhập chẩn đoán lâm sàng dựa trên NST đồ. Tích hợp AI phân tích chuyên sâu (tham chiếu y khoa) để đưa ra gợi ý hỗ trợ chẩn đoán.
- **FR-5 (Bước 5: Lập Báo cáo):** Cung cấp form soạn thảo báo cáo chuyên môn cuối cùng và nút "Gửi phê duyệt" để chuyển phiếu sang trạng thái `waitingApproval` cho Lab Manager.
- **FR-6 (Đồng bộ Layout):** Layout Workspace phải sử dụng chung `AppSideRail` và `AppHeader` của MainShell, nhưng có thêm thanh điều hướng quy trình (Stepper) 5 bước.

### Non-Functional Requirements
- **NFR-1 (Performance):** Quá trình kéo thả ở Bước 3 phải mượt mà đạt 60fps trên màn hình desktop, không bị giật lag khi re-render lưới NST.
- **NFR-2 (UX - Trạng thái AI):** Hiển thị rõ ràng trạng thái AI đang xử lý (Processing), Lỗi (Failed) hoặc Hoàn tất (Completed) để chuyên viên không bị bối rối.

## Acceptance Criteria
- [ ] **AC-1:** Stepper điều hướng hiển thị đúng 5 bước. Không cho phép click vào Bước 3 nếu chưa xong Bước 2, nhưng đang ở Bước 3 có thể click lùi về Bước 2.
- [ ] **AC-2:** Ở Bước 2, thao tác cắt/khoanh vùng cập nhật toạ độ ngay lập tức trên UI và chỉ lưu về backend khi nhấn "Xác nhận/Tiếp tục".
- [ ] **AC-3:** Ở Bước 3, kéo một NST từ khay chưa phân loại thả vào ô Số 1, UI cập nhật lập tức và 1.5 giây sau có một network request bắn lên server lưu toạ độ.
- [ ] **AC-4:** Khi AI đang phân tích cụm NST (từ B1 sang B2), hệ thống cho phép thoát Workspace, ngoài Dashboard hiện thanh Progress Bar chạy cho phiếu tương ứng.
- [ ] **AC-5:** Ở Bước 5, bấm Submit sẽ thay đổi trạng thái phiếu và điều hướng người dùng về lại Dashboard.

## Scenarios

### Scenario 1: Sửa lỗi AI bóc tách (Bước 2)
**Given** AI bóc tách dính 2 NST số 1 và số 2 thành một cụm.
**When** Specialist dùng công cụ Lasso khoanh vùng NST số 1, chọn lệnh "Cắt" và "Dán" ra chỗ trống.
**Then** Cụm ảnh gốc hiển thị đường cắt mảnh, toạ độ cắt (Polygon) được lưu Local. Dữ liệu chỉ được lưu lên Firestore và gửi cho FastAPI xử lý crop ảnh thực tế khi bấm "Tiếp tục".

### Scenario 2: Chờ AI trả kết quả
**Given** Specialist bấm "Bắt đầu bóc tách AI" sau khi chọn ảnh ở Bước 1.
**When** Hệ thống trả về trạng thái đang xử lý, Specialist bấm nút "Quay lại Dashboard".
**Then** Trên Dashboard, dòng phiếu bệnh nhân này hiện icon Lottie "Đang phân tích". 30 giây sau, icon đổi thành dấu check hoàn tất và thanh Sidebar hiện chấm đỏ ở mục Workspace.

## Technical Notes
- Để làm công cụ vẽ/cắt ở Bước 2, tham khảo các package Flutter như `image_painter` hoặc `extended_image` kết hợp canvas tuỳ chỉnh. Chỉ cần bóc xuất toạ độ vùng cắt (Path/Polygon) ra JSON để đẩy lên Firestore.
- Đối phó với Debouncing ở Bước 3: Sử dụng thư viện `rxdart` hoặc Timer logic trong Cubit/Riverpod để huỷ bỏ các request dư thừa nếu người dùng kéo thả liên tục.
