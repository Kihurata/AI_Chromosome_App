# Kế hoạch Cập nhật Module Receptionist (Update 2)

## 1. Phân tích Yêu cầu & Bối cảnh
Dựa trên phản hồi từ người dùng và thiết kế mới được cung cấp:
1. **Lỗi UI Layout Dashboard**: Chỉnh sửa layout để các Stat Cards và timeline Lịch hẹn luôn được neo sát lên phía trên (Header), loại bỏ khoảng trống thừa ở giữa trang.
2. **Nâng cấp Dropdown Bệnh nhân**: Nâng cấp popup tạo lịch hẹn. Ô chọn bệnh nhân sẽ mở ra một Custom Dropdown hiển thị ngay lập tức danh sách bệnh nhân (từ mới đến cũ). Đồng thời tích hợp thanh search để tìm kiếm theo tên hoặc CCCD ngay bên trong dropdown.
3. **Trang Xem Chi Tiết Bệnh Nhân (Dựa theo ảnh thiết kế mới)**:
   - Một trang chi tiết độc lập với cấu trúc rõ ràng.
   - **Header Card**: Chỉ chứa Họ Tên, Mã Bệnh Nhân (Patient Code), và SĐT (ẩn Avatar).
   - **Tab Navigation**: Hiển thị 2 tab chính cho Receptionist là "Thông tin Chi tiết" và "Lịch sử Khám bệnh". (Tab "Kết quả Xét nghiệm" được code sẵn nhưng ẩn đi với Role Receptionist, sẽ mở cho role khác sau).
   - **Tab Thông tin Chi tiết**: Liệt kê toàn bộ thông tin bệnh nhân, sử dụng thẻ Card và style thiết kế tương tự như tab Lịch sử khám bệnh.
   - **Tab Lịch sử Khám bệnh**: Giao diện dạng Timeline chiều dọc.
     - Mỗi lượt khám được thiết kế dưới dạng **Expandable Card** (Card có thể mở rộng/thu gọn).
     - **Trạng thái thu gọn**: Hiển thị Ngày, Giờ, Bác sĩ phụ trách, Loại hình khám (Ngoại trú/Tái khám/Cấp cứu) và Chẩn đoán sơ bộ (kèm mã ICD).
     - **Trạng thái mở rộng**: Xem chi tiết Lý do, Chỉ số sinh tồn (Vitals: Mạch, Huyết áp, Nhiệt độ, Cân nặng), Triệu chứng & Lâm sàng, Cận lâm sàng, Bảng kê Đơn thuốc, và Ghi chú/Lời dặn.

## 2. Task Breakdown (Chi tiết Triển khai)

| ID | Nhiệm vụ | Khu vực File | Chi tiết triển khai |
|---|---|---|---|
| **T1** | Căn chỉnh Dashboard TopCenter | `receptionist_dashboard_page.dart` | Sửa wrap property thành `Alignment.topCenter`, hoặc thay đổi cơ chế Layout của `AnimatedSwitcher` đảm bảo content (Cards, List) bung sát Header. |
| **T2** | Component Custom Dropdown Lịch Hẹn | `appointment_calendar_page.dart` (hoặc tạo widget rời) | - Tạo widget Custom Dropdown + Search Input.<br>- Khi tap, load Stream danh sách BN xếp theo `created_at` DESC.<br>- Lọc theo `identity_card` (CCCD) và danh tính. |
| **T3** | Xây dựng Patient Detail Page | `patient_detail_page.dart` (NEW) | - Header (Tên, Code, SĐT - KHÔNG Avatar).<br>- Hệ thống Tabs (ẩn tab Xét nghiệm với role Receptionist).<br>- Tab Thông tin chi tiết: UI dạng Card/Timeline.<br>- Tab Lịch sử: UI Timeline, Expandable Card.<br>- Tạm kết nối Mock Data. |
| **T4** | Tích hợp Navigation | `patient_list_page.dart` | Gắn sự kiện chuyển trang khi click icon "Xem chi tiết" (con mắt) tại Patient List sang trang `PatientDetailPage`. |

## 3. Verification Checklist (Tiêu chí Hoàn thành)
- [ ] Dashboard không bị khoảng trống giữa màn hình.
- [ ] Popup Tạo lịch hẹn: Ô "Bệnh nhân" nhấp vào sổ ra ngay danh sách BN mới nhất, gõ nội dung vào sẽ tìm kiếm theo CCCD/tên mượt mà.
- [ ] Click icon "Mắt" ở danh sách Bệnh nhân -> mở ra giao diện chi tiết đúng với layout thiết kế (Ảnh tab Lịch sử khám bệnh dạng Timeline).

## 4. Next Steps
Chờ xác nhận. Nếu bạn đồng ý với plan đã sửa đổi này, vui lòng gõ **"Tạo"** (hoặc `/create`) để tôi vận hành các sub-agents tiến hành viết code và nâng cấp UI!
