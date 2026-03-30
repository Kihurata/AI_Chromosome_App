# Kế hoạch thiết kế Module Clinician (Bác sĩ lâm sàng)

## 1. Overview & Mục Tiêu

Module dành riêng cho bộ phận Bác sĩ lâm sàng (`Clinician`). Dựa trên thiết kế và quyết định từ người dùng:
- **Sidebar**: Chỉ bao gồm 1 tab "Lịch hẹn" (Appointments) để tối giản trong giai đoạn MVP.
- **Danh sách Lịch hẹn**: Chỉ hiển thị các lịch hẹn được gán cho chính bác sĩ đang đăng nhập.
- **Form Khám Bệnh**: Bao gồm thông tin định danh bệnh nhân, Khám tổng quát (Lý do, Sinh hiệu), Diễn biến (Bệnh lý, Thực thể), Chẩn đoán (ICD-10 bằng Autocomplete), và Ghi chú.
- **Luồng xử lý**: Khi nhấn "Chỉ định Xét nghiệm", hệ thống sẽ nhắc nhở (hỏi) bác sĩ lưu thông tin khám bệnh trước khi tạo `test_orders` chuyển sang phòng lab.
- **Dữ liệu ICD-10**: Sử dụng danh mục 20 bệnh phổ biến làm dữ liệu mẫu (seed data) cho tính năng Autocomplete.

## 2. Project Type
**WEB** (Flutter Web)
*Lưu ý: Agent thực thi chính sẽ là `frontend-specialist` và có thể kết hợp `backend-specialist` để xử lý Firestore rules/seeding.*

## 3. Success Criteria
1. Bác sĩ đăng nhập thành công và chỉ thấy được các lịch hẹn của mình.
2. Form Khám Bệnh hiển thị đúng UI/UX theo bản thiết kế (Card-based, chia section rõ ràng).
3. Autocomplete ICD-10 hoạt động và query đúng từ Firestore collection `icd_codes`.
4. Khi nhấn "Chỉ định xét nghiệm", popup xác nhận việc "Lưu thông tin khám" hiện lên chính xác.
5. Sau khi xác nhận, thông tin khám bệnh được cập nhật kèm theo việc tạo 1 document `test_orders`.

## 4. Tech Stack & Architecture
- **Framework**: Flutter (Web).
- **Backend/DB**: Firebase Firestore.
- **State Management**: Provider (hoặc state management hiện hữu của project).
- **UI Libraries**: Tái sử dụng Theme (`AppColors`) và các widget có sẵn (như Sidebar layout pattern từ Receptionist).

## 5. File Structure Dự Kiến

```text
lib/data/models/
├── icd_code_model.dart (NEW - Model cho mã bệnh ICD-10)
├── medical_record_model.dart (NEW/MODIFY - Model lưu thông tin khám)

lib/data/repositories/
├── clinical_repository.dart (MODIFY - Thêm search ICD-10, getAppointmentsByDoctor)

lib/presentation/pages/clinician/
├── clinician_dashboard_page.dart (NEW - Tương tự receptionist_dashboard)
├── clinician_appointments_page.dart (NEW - Danh sách Lịch hẹn của bác sĩ)
├── medical_examination_page.dart (NEW - Form Khám Bệnh chính)

lib/presentation/widgets/clinician/
├── clinician_sidebar.dart (NEW - Sidebar với 1 tab Lịch hẹn)
├── clinician_header.dart (NEW - Header động)

scripts/
├── seed_icd_codes.py (NEW - Script Python để thêm 20 ICD-10 codes vào Firestore)
```

## 6. Task Breakdown

| ID | Task Name | Agent & Skill | Chi tiết (INPUT → OUTPUT → VERIFY) |
|----|-----------|---------------|------------------------------------|
| **T1** | **Setup & Seed Dữ liệu ICD-10** | `backend-specialist` (`python-patterns`) | **INPUT**: 20 mã bệnh ICD-10 phổ biến.<br>**OUTPUT**: Script `seed_icd_codes.py` và Collection `icd_codes` trên DB.<br>**VERIFY**: Chạy script thành công, Firestore có data. |
| **T2** | **Cập nhật Models & Repository** | `frontend-specialist` (`clean-code`) | **INPUT**: Bảng thiết kế Form khám bệnh.<br>**OUTPUT**: `IcdCodeModel`, `MedicalRecordModel`, và hàm `searchIcdCodes` trong Repo.<br>**VERIFY**: App build không lỗi, gọi Repo trả về data ICD-10. |
| **T3** | **Xây dựng UI Layout & Sidebar** | `frontend-specialist` (`frontend-design`) | **INPUT**: `ReceptionistDashboard` design pattern.<br>**OUTPUT**: `ClinicianDashboardPage` + Sidebar chỉ có mục "Lịch hẹn".<br>**VERIFY**: UI hiển thị đúng, responsive. |
| **T4** | **Danh sách Lịch hẹn (Bác sĩ)** | `frontend-specialist` (`clean-code`) | **INPUT**: `doctor_id` của user hiện tại.<br>**OUTPUT**: Danh sách lịch hẹn lọc theo bác sĩ, click vào mở Form khám.<br>**VERIFY**: Chỉ hiện lịch hẹn của bác sĩ đang login. |
| **T5** | **UI Form "Thông tin Khám bệnh"** | `frontend-specialist` (`frontend-design`) | **INPUT**: Ảnh mockup (Vitals, Khám tổng quát, ICD-10 Autocomplete).<br>**OUTPUT**: Trang `MedicalExaminationPage` với đầy đủ fields.<br>**VERIFY**: Nhập liệu mượt, UI Card clean, Autocomplete hiển thị suggestions đúng. |
| **T6** | **Xử lý Logic "Lưu" & "Chỉ định XN"** | `frontend-specialist` (`brainstorming`) | **INPUT**: Data từ form khám.<br>**OUTPUT**: Dialog hỏi có muốn lưu không khi nhấn "Chỉ định". Lưu form -> tạo `test_order` -> cập nhật status Lịch hẹn.<br>**VERIFY**: Test flow: Nhập form -> Click Chỉ định -> Bấm xác nhận lưu -> DB có thông tin khám + order mới. |

### Danh sách 20 mã ICD-10 Mẫu (Cho Task T1)
1. I10 - Essential (primary) hypertension
2. E78.5 - Hyperlipidemia, unspecified
3. Z00.00 - Encounter for general adult medical examination without abnormal findings
4. E11.9 - Type 2 diabetes mellitus without complications
5. J06.9 - Acute upper respiratory infection, unspecified
6. N39.0 - Urinary tract infection, site not specified
7. M54.50 - Low back pain, unspecified
8. J20.9 - Acute bronchitis, unspecified
9. E03.9 - Hypothyroidism, unspecified
10. K21.9 - Gastro-esophageal reflux disease without esophagitis
11. E55.9 - Vitamin D deficiency, unspecified
12. R05.9 - Cough, unspecified
13. J02.9 - Acute pharyngitis, unspecified
14. F41.9 - Anxiety disorder, unspecified
15. F32.9 - Major depressive disorder, single episode, unspecified
16. R53.83 - Other fatigue
17. R10.9 - Unspecified abdominal pain
18. R07.9 - Chest pain, unspecified
19. Z23 - Encounter for immunization
20. J18.9 - Pneumonia, unspecified organism

## 7. ✅ PHASE X: Verification Checklist
Sau khi hoàn thành T1-T6, thực hiện các bước sau:
- [ ] Chạy `flutter analyze` để đảm bảo không có cảnh báo/lỗi.
- [ ] Xác nhận Autocomplete ICD-10 hoạt động mượt mà không delay (debounce).
- [ ] Kiểm tra Sidebar Clinician chỉ có Lịch hẹn.
- [ ] Verify luồng Chỉ định xét nghiệm hiển thị Dialog xác nhận.
- [ ] Kiểm tra CSDL: Bệnh án và Test Order được gắn đúng Patient ID và Doctor ID.
- [ ] Không sử dụng mã màu violet/purple (theo rules).
- [ ] Màu sắc button Lưu (Primary), Huỷ (Secondary) tương đồng với Receptionist.

*Lưu ý: Không đánh dấu checklist này khi chưa thực hiện verify thực tế.*
