# Kế hoạch triển khai Factory Pattern cho Chi tiết Bệnh Nhân

## Mục tiêu
Tái cấu trúc (Refactor) giao diện Chi tiết Bệnh nhân (Patient Detail) hiện tại để hỗ trợ mô hình đa quyền (Multi-role) thông qua Design Pattern: **Factory Method**. Điều này cho phép hiển thị nội dung khác nhau hoàn toàn dựa trên Role đang đăng nhập (Lễ tân, Bác sĩ, Chuyên gia), thay vì dùng `if/else` chắp vá trong một file.

## Các giai đoạn triển khai (Giao việc cho Agents)

### Giai đoạn 1: Refactor Lõi & Giao diện (Do `frontend-specialist`)
1. **Đổi tên:** Đổi tên tệp giao diện hiện tại từ `patient_detail_page.dart` thành `receptionist_patient_detail_view.dart`.
2. **Setup Factory Component (Routing Wrapper):** Tạo file mới `patient_detail_page_factory.dart` đóng vai trò là Controller phân luồng giao diện dựa vào state của `AuthNotifier`.

### Giai đoạn 2: Bố trí Code Giao Diện rẽ nhánh (Do `frontend-specialist`)
1. Cấu trúc lại thư mục: Tạo thư mục `frontend/lib/presentation/screens/patient_detail/`.
2. Định nghĩa sơ bộ `doctor_patient_detail_view.dart` (Giao diện đơn giản dạng Placeholder để chứng minh hoạt động).
3. Đảm bảo AppRouter gọi tới Factory (tệp `patient_detail_page_factory.dart`) thay vì file view cứng.

### Giai đoạn 3: Kiểm định chất lượng (Do `test-engineer`)
1. Cập nhật các tệp Test liên quan (VD: `patient_list_page_test.dart` nếu bị ảnh hưởng do đường dẫn).
2. Chạy `lint_runner.py` để kiểm tra độ trơn tru và chuẩn Clean Code.
