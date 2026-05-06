## Overview
Đặc tả luồng xử lý giao diện (UI) cho cột "Hành động" (Quick Actions) trên trang Tổng Quan (Dashboard) của Specialist. Thiết kế này giải quyết vấn đề chồng chéo quy trình vật lý (lấy mẫu, nuôi cấy) và quy trình phần mềm (phân tích AI), đảm bảo Specialist chỉ thấy nút "Phân tích AI" khi ca xét nghiệm đã thực sự sẵn sàng.

## Locked Decisions
- **D1 (Separation of Concerns):** Trang Dashboard chỉ là nơi theo dõi tiến độ và kích hoạt phân tích AI. Các thao tác cập nhật quy trình vật lý (nuôi cấy, thu hoạch, tải ảnh) được đưa về trang "Quản lý mẫu".
- **D2 (Conditional CTA):** Nút Quick Action (Call-to-Action) trên Dashboard chỉ xuất hiện khi `TestOrder` đã sẵn sàng cho AI phân tích (đã tải ảnh lên).
- **D3 (Status Badges):** Với các ca chưa sẵn sàng, Dashboard sẽ hiển thị Badge Text (nhãn trạng thái) để thông báo lý do thay vì một nút bấm vô tác dụng.

## Requirements

### Functional Requirements
- **FR-1 (Trạng thái Chưa Sẵn Sàng):** Nếu TestOrder có status là `PENDING` (Chờ xử lý) hoặc `CULTURING` (Đang nuôi cấy), hệ thống KHÔNG hiển thị nút Quick Action. Thay vào đó hiển thị Badge Text tương ứng với status.
- **FR-2 (Trạng thái Sẵn Sàng):** Nếu TestOrder có status là `ANALYZING` (hoặc `READY_FOR_ANALYSIS`), hệ thống hiển thị nút Quick Action `🚀 Phân tích AI` (hoặc `Tiếp tục`).
- **FR-3 (Row Click / Navigation):** Khi người dùng click vào dòng (không click vào nút Quick Action), hệ thống sẽ mở trang **Chi tiết mẫu bệnh phẩm** (Sample Details) theo đúng spec.
- **FR-4 (Nút Quick Action Navigation):** Khi người dùng click vào nút `Phân tích AI`, hệ thống điều hướng trực tiếp vào màn hình **Workspace**.

### Non-Functional Requirements
- **NFR-1 (UI/UX):** Badge Text phải có màu sắc dịu (xám/vàng nhạt) để không thu hút sự chú ý bằng nút CTA chính (màu primary). Nút CTA phải nổi bật.

## Acceptance Criteria

- [ ] **AC-1:** Dashboard ẩn nút "Phân tích AI" đối với các TestOrder chưa có ảnh / đang nuôi cấy.
- [ ] **AC-2:** Dashboard hiển thị nhãn "Đang nuôi cấy" hoặc "Chờ xử lý" cho các TestOrder chưa sẵn sàng.
- [ ] **AC-3:** Dashboard hiển thị nút "Phân tích AI" cho các TestOrder đã tải ảnh và chuyển sang ANALYZING.
- [ ] **AC-4:** Bấm vào khoảng trống của Row sẽ mở trang Chi tiết Mẫu bệnh phẩm.
- [ ] **AC-5:** Bấm vào nút "Phân tích AI" sẽ mở thẳng vào Workspace Bước 1.

## Scenarios

### Scenario 1: Ca mới phân công đang trong Lab (Đang nuôi cấy)
**Given** Specialist cập nhật trạng thái mẫu sang CULTURING, kéo theo TestOrder.status = `CULTURING`.
**When** Specialist mở trang Dashboard.
**Then** Trên dòng của bệnh nhân đó, cột Hành động chỉ hiện Badge `⏳ Đang nuôi cấy` và không có nút bấm nào.

### Scenario 2: Ca đã tải ảnh thành công
**Given** Specialist vừa tải ảnh lên thành công ở trang Quản lý mẫu, TestOrder chuyển sang trạng thái sẵn sàng.
**When** Specialist quay lại trang Dashboard.
**Then** Trên dòng của bệnh nhân đó, cột Hành động hiện lên nút `🚀 Phân tích AI` màu xanh nổi bật.

### Scenario 3: Bắt đầu làm việc (Happy Path)
**Given** Dashboard đang hiện nút `🚀 Phân tích AI` cho bệnh nhân Nguyễn Văn A.
**When** Specialist bấm vào nút đó.
**Then** Trình duyệt chuyển hướng ngay lập tức vào Workspace Bước 1 để sàng lọc ảnh.

## Technical Notes
- Thêm logic kiểm tra `TestOrder.status` (hoặc `metaphase_images.isEmpty`) vào Component render Row của Table trong Dashboard.
- Có thể dùng `BlocBuilder` hoặc tính toán trực tiếp trong hàm `build` của Item Widget.
