# Kế hoạch Thực thi Frontend (Phased Execution Plan)

Dựa trên kết quả "quét" source code thực tế, tôi đã điều chỉnh lộ trình thực thi. Những phần nào team đã làm tốt, chúng ta sẽ giữ lại và tối ưu (Refactor) để code gọn gàng hơn. Những phần chưa có, chúng ta sẽ bắt tay vào code mới theo đúng chuẩn kiến trúc đã thống nhất.

---

## Tình trạng Source Code Hiện Tại (Audit)
- **Đã hoàn thành xuất sắc**: Cấu hình Firebase, Hệ thống Router (GoRouter), State Management (kết hợp Riverpod cho Global và BLoC cho Logic), Màn hình Login.
- **Đã có sẵn (Cần Refactor UI)**: Luồng của Role Receptionist (đã có đủ các file page và bloc, nhưng code UI trong page đang bị dài, thiếu các layout dùng chung).
- **Chưa có**: Các luồng cho Clinician, Manager, Specialist.

---

## Phase 1: Khởi tạo & Chuẩn hóa Nền tảng UI (Đã hoàn thành)
**Mục tiêu:** Tạo bộ khung Layout và Widget dùng chung từ những gì đã có sẵn, để chuẩn bị nền tảng "rút gọn" code cho các trang sau.

- `[x]` **1.1. Tái cấu trúc thư mục Shared Widgets**: Đã gom nhóm và phân bổ các file widget hiện hữu (`app_sidebar.dart`, `app_header.dart`, `status_badge.dart`...) vào đúng các thư mục con `navigation/`, `data_display/`, `layouts/` để tuân thủ kiến trúc.
- `[x]` **1.2. Tạo Global Layouts**:
  - Đã xây dựng xong `layouts/main_list_layout.dart` (Bố cục chứa sidebar và header).
  - Đã xây dựng xong `layouts/main_form_layout.dart`.
  - *(Chuẩn bị trước `medical_record_layout.dart` cho Phase 5 khi cần thiết).*
- `[x]` **1.3. Chuẩn hóa Data Display & Form**:
  - Tạo `data_display/app_data_table.dart` (Bọc lại data table hiện có để dùng chung search/phân trang).
  - Tách các Widget input (TextField, Dropdown, Button) ra thành các file `form/app_text_field.dart`, `form/app_buttons.dart` để tái sử dụng.

## Phase 2: Authentication & Role Management (Đã hoàn thành)
*(Giai đoạn này team đã làm rất tốt, không cần sửa đổi gì thêm)*
- `[x]` **Logic & Data Layer**: `auth_service.dart`, `auth_provider.dart`, `AuthCubit` đã hoàn thiện.
- `[x]` **UI Layer**: Giao diện `login_page.dart` đã xong.

## Phase 3: Tái cấu trúc (Refactor) Luồng Receptionist (Đã hoàn thành)
**Mục tiêu:** Áp dụng các component vừa tạo ở Phase 1 vào luồng Receptionist hiện có.
- `[x]` **3.1. Áp dụng Layouts vào các màn hình**: Đã áp dụng thành công `main_list_layout.dart`, `main_form_layout.dart` và các widget dùng chung vào màn hình của Receptionist (`patient_list_page.dart`, `appointment_calendar_page.dart`, `patient_registration_page.dart`...). Code giao diện đã được rút gọn đáng kể.
- `[x]` **3.2. Cập nhật Router và Import**: Đã rà soát và sửa lại toàn bộ đường dẫn (`import`) trên toàn dự án để tương thích tuyệt đối với cấu trúc thư mục mới. Hệ thống build không phát sinh lỗi, luồng điều hướng của Receptionist vẫn dùng `AppNavigationWrapper` và `GoRouter` chuẩn xác.

*(Từ Phase 4 trở đi, sẽ là quá trình code hoàn toàn mới. Nếu chưa có API, chúng ta sẽ bắt buộc áp dụng chiến lược Mock Data (chỉ sửa ở file Repository) để không cản trở tiến độ làm UI).*

---

## Phase 4: Clinician Features (Lịch khám & Các Form Chỉ định)
**Mục tiêu:** Xây dựng màn hình danh sách lịch khám và các phiếu chỉ định.
- `[x]` **4.1. Repositories & BLoC**: Khởi tạo logic (Sử dụng Mock Data).
- `[x]` **4.2. Appointment List Screen**: Tạo UI danh sách lịch khám cho bác sĩ.
- `[x]` **4.3. Form Chỉ định**: Tạo UI cho `examination_form_screen` (Phiếu khám bệnh) và `blood_test_prescription_screen` (Phiếu xét nghiệm máu).

## Phase 5: Clinician Features (Medical Record - Bệnh án Điện tử)
**Mục tiêu:** Xây dựng màn hình Bệnh án phức tạp với cấu trúc dọc và Tab Navigation.
- `[x]` **5.1. Repositories & BLoC**: Khởi tạo logic bệnh án (Mock Data).
- `[x]` **5.2. Medical Record Screen (Root)**: Xây dựng Layout bệnh án (Header + Profile Summary + Tabs).
- `[x]` **5.3. Local Widgets & Sections**: Xây dựng chi tiết từng Tab (General Info, Medical History, Test Results).

## Phase 6: Manager Features (Quản lý Xét nghiệm)
**Mục tiêu:** Màn hình duyệt ca xét nghiệm.
- `[ ]` **6.1. Repositories & BLoC**: (Mock Data).
- `[ ]` **6.2. Lab Test List & Assigning**: Giao diện danh sách và Form Dialog gán Specialist.
- `[ ]` **6.3. Approve Lab Test Screen**: Giao diện hiển thị kết quả và nút duyệt (ký số).

## Phase 7: Specialist Features (Xử lý Mẫu Bệnh phẩm)
**Mục tiêu:** Màn hình cho người thực hiện nuôi cấy.
- `[ ]` **7.1. Repositories & BLoC**: (Mock Data).
- `[ ]` **7.2. Assigned Lab Tests Screen**: Danh sách công việc được giao.
- `[ ]` **7.3. Lab Test Detail Screen**: Màn hình chi tiết chứa danh sách mẫu bệnh phẩm và Dropdown cập nhật tiến độ nuôi cấy.
