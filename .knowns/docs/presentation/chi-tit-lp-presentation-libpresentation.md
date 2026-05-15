---
title: Chi tiết lớp Presentation (lib/presentation)
description: Tài liệu chi tiết về lớp Presentation (lib/presentation), bao gồm Screens, Widgets, và Utils.
createdAt: '2026-05-13T14:53:54.810Z'
updatedAt: '2026-05-13T14:54:13.155Z'
tags:
  - architecture
  - presentation-layer
  - clean-architecture
  - ui
---

# Chi tiết lớp Presentation (`lib/presentation`)

## 1. Vai trò
Lớp Presentation (Giao diện) chịu trách nhiệm hiển thị thông tin cho người dùng và tiếp nhận các sự kiện tương tác (chạm, lướt, nhập liệu...). Đây là lớp **duy nhất** trong mô hình Clean Architecture phụ thuộc trực tiếp vào Flutter framework (UI widgets).

Nguyên tắc quan trọng: Lớp này **không** thực hiện tính toán nghiệp vụ hay lưu trữ dữ liệu trực tiếp. Thay vào đó, nó lắng nghe trạng thái từ lớp Logic (qua Cubit hoặc Riverpod) để vẽ màn hình và gọi hàm của Cubit khi cần xử lý hành động.

## 2. Cấu trúc chi tiết

### 📁 `screens/`
Thư mục này chứa các màn hình (Pages/Screens) hoàn chỉnh của ứng dụng. Mỗi file thường đại diện cho một trang có thể điều hướng tới (chứa `Scaffold`).
Các màn hình được tổ chức theo module tính năng hoặc vai trò (Role) người dùng:
- `auth/`: Màn hình liên quan đến xác thực (Đăng nhập, Forgot Password).
- `clinician/`, `manager/`, `receptionist/`, `specialist/`: Màn hình Dashboard và chức năng cụ thể tương ứng với từng vai trò.
- `workspace/`: Luồng màn hình phục vụ cho không gian làm việc chuyên biệt (ví dụ: các bước phân tích NST của Specialist).
- `patient_detail/`: Màn hình hiển thị chi tiết hồ sơ bệnh nhân.

### 📁 `widgets/`
Chứa các thành phần giao diện nhỏ (UI Components), có tính độc lập cao và dễ dàng tái sử dụng. Việc tách widget giúp code màn hình ngắn gọn, dễ bảo trì hơn.
Cũng giống `screens`, `widgets` được chia nhóm một cách logic:
- `shared/`: Chứa các widget được tái sử dụng trên toàn hệ thống (Custom Buttons, Text Fields, Cards, Loading Indicators...).
- `dashboard/`: Các widget chung phục vụ cho cấu trúc của màn hình Dashboard.
- `manager/`, `receptionist/`, `specialist/`: Các widget đặc thù, chỉ hiển thị trong màn hình của một vai trò nhất định (ví dụ: Biểu đồ thống kê riêng của Manager).

### 📁 `utils/`
Chứa các file định nghĩa hàm tiện ích (Helper functions) phục vụ riêng cho tầng UI.
- File tiêu biểu: `ui_utils.dart`.
- Có thể chứa các hàm hỗ trợ như:
  - Hiển thị Toast thông báo, Snackbar, hay Dialog cảnh báo.
  - Xử lý định dạng dữ liệu (Formatting) để hiển thị (chuyển đổi định dạng ngày tháng, tiền tệ...).
  - Helper xử lý kích thước (Responsive dimensions).

---
Tài liệu này bổ sung chi tiết cho mục `lib/presentation` trong @doc/presentation/cu-trc-th-mc-lib-v-kin-trc-ng-dng.
