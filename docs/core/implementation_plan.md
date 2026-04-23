# Kế hoạch Kiến trúc & Cấu trúc Thư mục Frontend (Flutter Web) - Đã Cập Nhật

Dựa trên các thông tin bổ sung cực kỳ chi tiết của bạn về thiết kế UI, điều hướng (go_router), quản lý state (flutter_bloc) và việc **các Role hoạt động hoàn toàn độc lập (không truy cập chéo)**, tôi đã điều chỉnh lại cấu trúc thư mục. 

Điểm nhấn quan trọng nhất ở đây là việc **tách biệt các Screens theo từng Role** để dễ quản lý luồng đi (flow), kết hợp với tầng **Logic theo Feature** để tối ưu hóa tái sử dụng code, **áp dụng Clean Architecture với tầng Domain độc lập** để đảm bảo khả năng mở rộng lâu dài, đồng thời **tập trung tối đa vào việc tái sử dụng UI Layouts** trong thư mục `widgets`.

---

## 1. Đề xuất Cấu trúc Thư mục Chi tiết

```text
lib/
├── core/
│   ├── constants/              # App colors, text styles, role_constants, api_endpoints...
│   ├── di/                     # Dependency Injection (get_it, injectable) setup
│   ├── errors/                 # Xử lý Exception, Failure, Global error handling
│   ├── network/                # Cấu hình Dio/HTTP client, Interceptors
│   ├── router/                 # Quản lý Navigation bằng go_router
│   │   ├── app_router.dart     # Định nghĩa cấu trúc route (VD: /receptionist/patients)
│   │   └── route_guards.dart   # Middleware kiểm tra Role trước khi vào route
│   └── utils/                  # Các hàm tiện ích (format ngày, parse chuỗi...)
│
├── domain/                     # 🌟 TẦNG CỐT LÕI (Không phụ thuộc Framework/UI/Data)
│   ├── entities/               # Dữ liệu thuần (VD: Patient, LabTest, Appointment)
│   ├── repositories/           # Chỉ chứa INTERFACE (VD: abstract class ILabTestRepository)
│   └── usecases/               # Logic nghiệp vụ phức tạp (VD: ApproveLabTestUseCase)
│
├── data/                       # Tầng Data (Cung cấp dữ liệu cho Domain)
│   ├── models/                 # Kế thừa/Map với Entities, có chứa fromJson/toJson
│   ├── datasources/            # Chứa API calls (Dio), Local DB
│   └── repositories/           # IMPLEMENTATION của Interfaces ở tầng Domain
│
├── logic/                      # Tầng Business Logic (Feature-based, quản lý userRole)
│   ├── auth/                   # Xử lý Login, Logout, Session, lưu trữ Role hiện tại
│   │   └── auth_bloc.dart
│   ├── patient/                # Quản lý Bệnh nhân (Dùng chung cho Lễ tân, Bác sĩ...)
│   │   ├── patient_list_bloc.dart
│   │   └── patient_detail_bloc.dart
│   ├── appointment/            # Quản lý Lịch hẹn (Dùng chung)
│   │   ├── appointment_list_bloc.dart
│   │   └── manage_appointment_bloc.dart
│   ├── medical_record/         # Quản lý Bệnh án
│   │   ├── medical_record_bloc.dart
│   │   └── examination_form_bloc.dart
│   └── lab_test/               # Quản lý Xét nghiệm (Dùng chung cho Manager & Specialist)
│       ├── lab_test_list_bloc.dart
│       ├── lab_test_approval_bloc.dart  # Kiểm tra userRole == manager bên trong BLoC
│       └── specimen_tracking_bloc.dart  # Kiểm tra userRole == specialist bên trong BLoC
│
└── presentation/               # Tầng UI (Vẫn giữ theo Role vì không có truy cập chéo)
    ├── widgets/                # UI Components tái sử dụng CAO
    │   ├── buttons/            # Các Custom Buttons (Primary, Secondary, Outline, Text...)
    │   ├── inputs/             # Các Custom TextFields, Dropdowns, Checkbox, DatePicker...
    │   ├── layouts/            # Các khung Layout chính
    │   │   ├── main_list_layout.dart       # Bố cục Danh sách: Sidebar + Right(Header + List Container)
    │   │   ├── main_form_layout.dart       # Bố cục Lập phiếu: Sidebar + Right(Header + Form Container)
    │   │   └── medical_record_layout.dart  # Bố cục dọc cho Bệnh án: Header + Container(Nav, Profile, Tabs)
    │   ├── common/             # Các thành phần cấu thành Layout
    │   │   ├── custom_sidebar.dart         # Sidebar động nhận input list menu item
    │   │   ├── custom_header.dart          # Header động (có Text/Icon/User info)
    │   │   ├── data_table_view.dart        # Table chuẩn: Header table, Search, Phân trang, List động
    │   │   └── form_container.dart         # Wrapper có style chuẩn cho các Form nhập liệu
    │   └── dialogs/            # Các Dialog dùng chung
    │
    └── screens/                # Nhóm theo ROLE vì không có truy cập chéo
        ├── auth/
        │   └── login_page.dart
        ├── receptionist/
        │   ├── patient_list_screen.dart
        │   ├── add_patient_screen.dart         # Pop về list sau khi Lưu/Hủy
        │   └── create_appointment_screen.dart  # Pop về list sau khi Lưu/Hủy
        ├── clinician/
        │   ├── appointment_list_screen.dart
        │   ├── medical_record/
        │   │   ├── medical_record_screen.dart  # Dùng medical_record_layout.dart
        │   │   └── tabs/
        │   │       ├── general_info_tab.dart
        │   │       ├── medical_history_tab.dart
        │   │       └── test_results_tab.dart
        │   ├── examination_form_screen.dart    # Truy cập từ Header của mọi Tab bệnh án
        │   └── blood_test_prescription_screen.dart # Pop về danh sách lịch khám
        ├── manager/
        │   ├── lab_test_list_screen.dart       # Chứa logic mở Dialog giao việc
        │   ├── widgets/
        │   │   └── assign_specialist_dialog.dart # Form hiển thị giữa màn hình khi bấm nút "Giao việc"
        │   └── approve_lab_test_screen.dart    # Pop về danh sách sau khi Ký số/Hủy
        └── specialist/
            ├── assigned_lab_tests_screen.dart
            └── lab_test_detail/
                ├── lab_test_detail_screen.dart # Danh sách các mẫu bệnh phẩm
                └── widgets/
                    └── culture_process_dropdown.dart # Dropdown thay đổi trạng thái nuôi cấy
```

> [!NOTE]
> **Giải pháp tái sử dụng giao diện (UI Reusability):**
> Nhờ cách chia `layouts/` và `common/`, việc tạo một màn hình danh sách mới (ví dụ `patient_list_screen.dart`) sẽ chỉ đơn giản là gọi Widget `MainListLayout`, truyền vào danh sách cấu hình Sidebar phù hợp cho Receptionist, một cái Header có nút "Thêm Bệnh nhân", và body là `DataTableView` chứa cấu hình các cột tương ứng.

---

## 2. Chiến lược Routing với Go Router

Với `go_router`, chúng ta sẽ thiết lập luồng đi (flow) theo mô hình hướng Role.

- `GoRoute(path: '/login')`
- `GoRoute(path: '/receptionist')`: Redirect về `/receptionist/patients`
  - `GoRoute(path: 'patients')`
  - `GoRoute(path: 'add-patient')`
  - `GoRoute(path: 'create-appointment')`
- `GoRoute(path: '/clinician')`: Redirect về `/clinician/appointments`
  - `GoRoute(path: 'appointments')`
  - `GoRoute(path: 'medical-record/:appointmentId')` (Nhận parameter để tải dữ liệu)
  - `GoRoute(path: 'examination-form/:appointmentId')`
  - `GoRoute(path: 'blood-test-prescription/:appointmentId')`
- Tương tự cho `manager` và `specialist`.

Khi các màn hình form hoàn thành tác vụ (Lưu/Hủy), chỉ cần gọi `context.pop()` (như bạn yêu cầu "quay về trang trước đó") thay vì gọi `context.go()` để đẩy trang mới. Điều này giúp lịch sử điều hướng mượt mà và đúng chuẩn.

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


