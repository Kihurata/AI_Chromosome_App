---
title: Chi tiết lớp Data (lib/data)
description: Tài liệu chi tiết về lớp Data (lib/data), bao gồm DataSources, Models và Repository Implementations.
createdAt: '2026-05-13T07:50:48.681Z'
updatedAt: '2026-05-13T07:50:54.933Z'
tags:
  - architecture
  - data-layer
  - clean-architecture
---

# Chi tiết lớp Data (`lib/data`)

## 1. Vai trò
Lớp Data (Data Layer) chịu trách nhiệm giao tiếp với các nguồn dữ liệu bên ngoài (External Data Sources) như Firebase Firestore, Firebase Storage, hoặc các REST API. 
Nó hiện thực hóa (implement) các abstract interface được định nghĩa ở lớp Domain và chuyển đổi dữ liệu thô thành các đối tượng có cấu trúc.

## 2. Cấu trúc chi tiết

### 📁 `datasources/`
Đây là nơi thực hiện các truy vấn thô (Raw Queries) đến DB hoặc API. Các file ở đây không chứa logic nghiệp vụ mà chỉ tập trung vào việc lấy dữ liệu về.
- Sử dụng `FirebaseFirestore.instance` để get/set dữ liệu.
- Ví dụ thực tế trong dự án:
  - `patient_remote_datasource.dart`: Truy vấn thông tin bệnh nhân.
  - `sample_remote_datasource.dart`: Truy vấn thông tin mẫu bệnh phẩm.
  - `test_order_remote_datasource.dart`: Quản lý các lệnh xét nghiệm.

### 📁 `models/`
Chứa các Data Model. Các model này thường "extends" hoặc implements các Entity từ lớp Domain nhưng được bổ sung thêm các phương thức hỗ trợ Serialization/Deserialization.
- Chứa các hàm factory như `fromFirestore()`, `fromMap()`, `toJson()`.
- Mục đích: Cách ly lớp Domain khỏi cách thức dữ liệu được lưu trữ (ví dụ: Firestore dùng Map, API dùng JSON).

### 📁 `repositories/`
Chứa các file triển khai cụ thể (Implementation) của các Repository Interface từ lớp Domain.
- Tên file luôn kết thúc bằng `_impl.dart` (ví dụ: `patient_repository_impl.dart`).
- Nhiệm vụ: Gọi đến các Data Source tương ứng, bắt lỗi (Exception), chuyển đổi dữ liệu thành Model/Entity và trả về cho lớp Logic hoặc Domain.
- Ví dụ thực tế trong dự án:
  - `patient_repository_impl.dart`
  - `sample_repository_impl.dart`
  - `workspace_repository_impl.dart` (Chứa logic xử lý nặng ký cho Workspace của Specialist).

---
Tài liệu này bổ sung chi tiết cho mục `lib/data` trong @doc/presentation/cu-trc-th-mc-lib-v-kin-trc-ng-dng.
