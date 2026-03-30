# Kế hoạch Kiểm thử Module Receptionist (Tiếp tân)

## 1. Overview & Scope

Kế hoạch này vạch ra các kịch bản kiểm thử (Test Cases) cho Module Receptionist vừa được hoàn thiện. Phạm vi kiểm thử bao gồm:
- **Unit Tests**: Kiểm tra logic của `ClinicalRepository` (tìm kiếm, check trùng lặp).
- **Widget Tests**: Kiểm tra các UI component (`ReceptionistSidebar`, `PatientRegistrationPage`, `AppointmentCalendarPage`).
- **Integration Tests (nếu cần)**: End-to-end flow từ nhập form đến lưu DB.

## 2. Test Breakdown

### 2.1 Unit Tests (Data Layer)
**Mục tiêu**: `frontend/test/data/repositories/clinical_repository_test.dart`
- [ ] `checkDuplicatePatient`: Trả về `PatientModel` khi CCCD đã tồn tại.
- [ ] `checkDuplicatePatient`: Trả về `null` khi CCCD và SĐT chưa tồn tại.
- [ ] `searchPatients`: Trả về danh sách bệnh nhân khớp với từ khóa (Tên/SĐT/CCCD).
- [ ] `searchPatients`: Trả về list rỗng khi không có kết quả.

### 2.2 Widget Tests (UI Layer)

**A. Form Đăng ký Bệnh nhân (`patient_registration_page_test.dart`)**
- [ ] Render đầy đủ 2 section (Thông tin định danh & Địa chỉ).
- [ ] Validation errors hiển thị đúng khi bỏ trống các trường bắt buộc (Tên, CCCD, SĐT, Ngày sinh).
- [ ] Trạng thái Duplicate Warning hiển thị khi nhập CCCD bị trùng (Mock Repository).
- [ ] Cascading Dropdowns: Reset Quận/Huyện khi Tỉnh/TP thay đổi.

**B. Danh sách Bệnh nhân (`patient_list_page_test.dart`)**
- [ ] Hiển thị Empty State khi chưa có bệnh nhân.
- [ ] Hiển thị danh sách và áp dụng mask cho CCCD `(0012********)`.
- [ ] Filter hoạt động: Nhập test query và verify số lượng row hiển thị.

**C. Layout & Sidebar (`receptionist_dashboard_page_test.dart`)**
- [ ] Nhấp vào "Bệnh nhân" ở Sidebar -> Render `PatientListPage`.
- [ ] Nhấp vào "Lịch khám" -> Render `AppointmentCalendarPage`.

**D. Calendar View (`appointment_calendar_page_test.dart`)**
- [ ] Nút "Tạo lịch hẹn" mở ra popup dialog.
- [ ] Popup Dialog chứa Autocomplete patient và Dropdown chọn bác sĩ.

## 3. Libraries & Dependencies cần thiết
- `flutter_test` (có sẵn)
- `mockito` hoặc `mocktail` (để mock Firebase Firestore / Repository)

## 4. Phase X: Verification Plan
- Quét coverage (`flutter test --coverage`).
- Đảm bảo tất cả tests pass (`All tests passed`).
- Cập nhật Walkthrough với kết quả.
