# Kế hoạch Kiến trúc & Cấu trúc Thư mục Frontend (Flutter Web) - Đã Cập Nhật Lần 4

Sau khi "soi" tận gốc source code của bạn, tôi nhận ra bạn của bạn đã thiết lập một bộ khung rất chất lượng (Hybrid giữa BLoC và Riverpod, tích hợp Firebase). Để tôn trọng công sức đó và tránh phá vỡ code đang chạy tốt, tôi đã **điều chỉnh lại bản đồ cấu trúc thư mục này sao cho "khớp" 100% với những gì đã có sẵn**, đồng thời vẫn áp dụng quy tắc chia nhỏ (Local Widgets) và gom nhóm (Global Widgets) để tối ưu cho tương lai.

---

## 1. Đề xuất Cấu trúc Thư mục Chi tiết (Đồng bộ với Source Code)

```text
lib/
├── core/                       # Tầng Core hiện hữu đã rất tốt
│   ├── config/                 # (Có sẵn) app_nav_items.dart
│   ├── firebase/               # (Có sẵn) Cấu hình Firebase
│   ├── models/                 # (Có sẵn) Các model dùng cho logic app (nav_item.dart)
│   ├── providers/              # (CÓ SẴN - RẤT QUAN TRỌNG) Riverpod Providers (auth_provider.dart, nav_provider.dart)
│   ├── router/                 # (Có sẵn) app_router.dart
│   ├── services/               # (Có sẵn) auth_service.dart (Firebase Auth)
│   └── theme/                  # (Có sẵn) app_colors.dart, app_theme.dart
│
├── data/                       # Tầng Data (API, Models) - Đã có sẵn
│   ├── models/                 # patient_model.dart, appointment_model.dart...
│   ├── datasources/            # patient_remote_datasource.dart...
│   └── repositories/           # patient_repository.dart, appointment_repository.dart...
│
├── logic/                      
│   └── bloc/                   # (Có sẵn) Chứa các thư mục Cubit/Bloc
│       ├── auth/               # auth_cubit.dart
│       ├── patient/            # patient_cubit.dart
│       ├── workspace/          
│       ├── clinician/          # (Sẽ tạo mới)
│       ├── manager/            # (Sẽ tạo mới)
│       └── specialist/         # (Sẽ tạo mới)
│
└── presentation/               # Tầng UI (Nơi chúng ta quy hoạch lại cho gọn gàng)
    ├── widgets/                
    │   ├── shared/             # (Kế thừa từ có sẵn) Global Widgets dùng chung toàn app
    │   │   ├── layouts/        # (Mới) main_list_layout.dart, main_form_layout.dart, medical_record_layout.dart
    │   │   ├── navigation/     # app_sidebar.dart, app_header.dart, sidebar_base.dart
    │   │   ├── data_display/   # (Mới) app_data_table.dart, status_badge.dart
    │   │   ├── form/           # (Mới) app_text_field.dart, app_buttons.dart
    │   │   └── feedback/       # (Mới) app_dialog.dart, loading_overlay.dart
    │   │
    │   ├── receptionist/       # (Có sẵn) Những widget chỉ dùng nhiều lần trong luồng Receptionist
    │   │   ├── receptionist_sidebar.dart
    │   │   └── receptionist_header.dart
    │   └── dashboard/          # (Có sẵn) recent_patients_table.dart
    │
    └── screens/                # Nhóm theo ROLE
        ├── auth/               # (Có sẵn) login_page.dart
        ├── dashboard/          # (Có sẵn) doctor_dashboard_page.dart
        ├── patient_detail/     # (Có sẵn) 
        ├── receptionist/       # (CÓ SẴN - Đã tiến hành Refactor/Lắp ráp lại)
        │   ├── patient_list_page.dart
        │   ├── create_appointment_page.dart
        │   ├── appointment_calendar_page.dart
        │   ├── patient_registration_page.dart
        │   └── receptionist_dashboard_page.dart
        ├── clinician/          # (Sẽ tạo mới ở Phase 4, 5)
        │   ├── appointment_list/
        │   │   ├── appointment_list_screen.dart
        │   │   └── widgets/
        │   │       └── appointment_action_buttons.dart
        │   ├── medical_record/ # Áp dụng quy tắc "Local Widgets" ngay cạnh màn hình lớn
        │   │   ├── medical_record_screen.dart
        │   │   └── widgets/
        │   │       ├── patient_summary_card.dart
        │   │       ├── medical_record_tab_bar.dart
        │   │       ├── general_info_section.dart
        │   │       ├── medical_history_section.dart
        │   │       ├── test_results_section.dart
        │   │       └── medical_record_action_bar.dart
        │   ├── examination_form_screen.dart
        │   └── blood_test_prescription_screen.dart
        ├── manager/            # (Sẽ tạo mới ở Phase 6)
        │   ├── lab_test_list/
        │   │   ├── lab_test_list_screen.dart
        │   │   └── widgets/
        │   │       ├── lab_test_table.dart
        │   │       ├── assign_specialist_dialog.dart
        │   │       ├── assign_specialist_form.dart
        │   │       └── lab_test_list_header_actions.dart
        │   └── approve_lab_test_screen.dart
        └── specialist/         # (Sẽ tạo mới ở Phase 7)
            ├── assigned_lab_tests_screen.dart
            └── lab_test_detail/
                ├── lab_test_detail_screen.dart
                └── widgets/
                    ├── specimen_list_section.dart
                    └── culture_process_dropdown.dart
```

---

## 2. Chiến lược Routing với Go Router & Riverpod

Dựa vào `nav_provider.dart` và `auth_provider.dart` hiện tại:
- Router tiếp tục sử dụng `flutter_riverpod` (`AuthNotifier`) để kiểm tra quyền truy cập (redirect).
- Việc điều hướng nội bộ và Render Sidebar động tiếp tục tận dụng `config/app_nav_items.dart` và `nav_provider.dart`.

**Cấu trúc Cây định tuyến (Route Tree) dự kiến:**
- `GoRoute(path: '/login')`
- `GoRoute(path: '/receptionist')`: Redirect về `/receptionist/patients`
  - `GoRoute(path: 'patients')`
  - `GoRoute(path: 'add-patient')`
  - `GoRoute(path: 'create-appointment')`
- `GoRoute(path: '/clinician')`: Redirect về `/clinician/appointments`
  - `GoRoute(path: 'appointments')`
  - `GoRoute(path: 'medical-record/:appointmentId')`
  - `GoRoute(path: 'examination-form/:appointmentId')`
  - `GoRoute(path: 'blood-test-prescription/:appointmentId')`
- Tương tự cho các nhánh của `manager` (như `/manager/lab-tests`) và `specialist`.

---

## 3. Danh sách API Endpoints Cần thiết (Bổ sung đầy đủ)

**Auth & User**
- `POST /api/auth/login`
- `GET /api/auth/me`

**Patient (Receptionist & Clinician)**
- `GET /api/patients`
- `POST /api/patients`
- `GET /api/patients/{id}` *(Xem hồ sơ bệnh nhân chi tiết)*

**Appointment (Receptionist & Clinician)**
- `POST /api/appointments`
- `GET /api/appointments`
- `GET /api/appointments/{id}`
- `PATCH /api/appointments/{id}/status` *(Cập nhật trạng thái: chờ khám, đang khám, hoàn tất)*

**Medical Record (Clinician)**
- `GET /api/medical-records/by-appointment/{appointmentId}` *(Thuận tiện cho UI đi từ lịch khám)*
- `GET /api/medical-records/{patientId}/history`
- `GET /api/medical-records/{patientId}/test-results`
- `POST /api/medical-records/{patientId}/examinations` 
- `POST /api/lab-tests/prescriptions` 

**Lab Test (Manager & Specialist)**
- `GET /api/lab-tests` 
- `GET /api/lab-tests/{id}` *(Endpoint bundle trả về đầy đủ ca + specimens + process history)*
- `GET /api/specialists` *(Để Manager gán ca cho specialist trong dialog)*
- `PUT /api/lab-tests/{id}/assign` 
- `PUT /api/lab-tests/{id}/approve` 
- `GET /api/lab-tests/{id}/specimens` 
- `PUT /api/specimens/{specimenId}/status` 
- `GET /api/specimens/{id}/process-history` *(Xem lịch sử quá trình cập nhật của mẫu)*

---

## 4. Chốt Kế Hoạch Thực Thi

Do code UI và Logic của màn hình Receptionist đã chạy tốt (nhưng file UI có thể đang bị to do chưa chia cắt chuẩn), **Phase tiếp theo của chúng ta sẽ là**:
1. Không code lại từ đầu màn hình Receptionist nữa.
2. Chúng ta sẽ mở các file như `patient_list_page.dart` hay `patient_registration_page.dart` ra.
3. Tạo các thư mục `data_display`, `form`, `layouts` bên trong `widgets/shared/` và di chuyển những đoạn code (như Table, Button, Text Field) lặp lại ở các trang đó vào đây.
4. Gắn `main_list_layout.dart` vào để code UI gọn lại chỉ còn vài chục dòng thay vì hàng trăm dòng.

*(Ghi chú: Phase 1, 2, 3 liên quan đến Refactor Receptionist và Shared Widget đã được hoàn thành)*
