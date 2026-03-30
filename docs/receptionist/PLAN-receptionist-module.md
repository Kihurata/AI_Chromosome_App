# Kế hoạch thiết kế Module Receptionist (Tiếp tân)

## 1. Overview & Mục Tiêu

Module dành riêng cho bộ phận Tiếp tân (`Receptionist`) với 3 chức năng chính trong Sidebar:
1. **Tổng quan (Dashboard)** - Thống kê ngày
2. **Bệnh Nhân (Patients)** - Quản lý hồ sơ bệnh nhân
3. **Lịch Khám (Appointments)** - Calendar View

## 2. Design Concept (Từ Screen Design Đính Kèm)

Form "Tiếp nhận bệnh nhân tại quầy" chia 2 section card:
- **Section 1: Thông tin định danh (Bắt buộc)** - Họ tên, CCCD/Hộ chiếu, Ngày sinh, SĐT, Giới tính (Radio: Nam/Nữ/Khác)
- **Section 2: Địa chỉ & Liên lạc** - Tỉnh/TP, Quận/Huyện, Phường/Xã (cascading dropdown), Số nhà, Người liên hệ khẩn cấp, SĐT người thân
- Actions: "Huỷ bỏ" (Outlined) + "Lưu hồ sơ" (Primary Blue with save icon)
- UI Style: Clean card-based layout, subtle shadows, blue accent, Inter font

## 3. Database Schema Cập Nhật

### `patients` (Bổ sung từ ARCHITECTURE.md)
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Primary Key |
| `patient_code` | `String` | Auto-generated (MÃ BN) |
| `full_name` | `String` | Bắt buộc |
| `identity_card` | `String` | CCCD / Hộ chiếu (check trùng) |
| `dob` | `Date` | DD/MM/YYYY |
| `gender` | `String` | Nam / Nữ / Khác |
| `contact` | `String` | SĐT chính |
| `province` | `String` | Tỉnh/Thành phố |
| `district` | `String` | Quận/Huyện |
| `ward` | `String` | Phường/Xã |
| `address` | `String` | Số nhà, Tên đường |
| `emergency_contact_name` | `String` | Người liên hệ khẩn cấp |
| `emergency_contact_phone` | `String` | SĐT người thân |
| `status` | `String` | `active`, `inactive` |
| `created_at` | `Timestamp` | |

## 4. File Structure

```text
lib/data/models/
├── patient_model.dart (MODIFY - thêm fields mới)

lib/data/repositories/
├── clinical_repository.dart (MODIFY - thêm methods search/check duplicate)

lib/presentation/pages/receptionist/
├── receptionist_dashboard_page.dart (MODIFY - refactor thành layout + sidebar nav)
├── patient_list_page.dart (NEW - danh sách BN + search)
├── patient_registration_page.dart (MODIFY - redesign theo screen concept)
├── appointment_calendar_page.dart (NEW - Calendar View)

lib/presentation/widgets/receptionist/
├── receptionist_sidebar.dart (MODIFY - chỉ giữ 3 menu chính)
├── receptionist_header.dart (MODIFY - dynamic title theo page)
├── today_appointments_table.dart (giữ nguyên)
```

## 5. Task Breakdown

| ID | Task | Priority |
|----|------|----------|
| T1 | Cập nhật PatientModel + Repository (thêm fields, check trùng) | P0 |
| T2 | Refactor Sidebar (3 mục) + Layout Navigation | P1 |
| T3 | Redesign Patient Registration Form (theo screen concept) | P1 |
| T4 | Patient List Page (search, DataTable) | P1 |
| T5 | Appointment Calendar Page (table_calendar) | P2 |
| T6 | Cập nhật Header dynamic theo page | P2 |

## 6. Phase X: Verification
- [ ] `flutter analyze` không lỗi
- [ ] Sidebar chuyển tab mượt mà
- [ ] Form validate + check trùng CCCD/SĐT
- [ ] Calendar hiển thị lịch khám đúng ngày
