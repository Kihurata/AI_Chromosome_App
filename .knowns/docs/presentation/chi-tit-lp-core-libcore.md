---
title: Chi tiết lớp Core (lib/core)
description: Tài liệu chi tiết về lớp Core (lib/core), bao gồm Config, Providers, Router, và Services.
createdAt: '2026-05-14T07:08:26.665Z'
updatedAt: '2026-05-14T08:02:51.312Z'
tags:
  - architecture
  - core-layer
  - clean-architecture
---

# Chi tiết lớp Core (`lib/core`)

## 1. Vai trò
Lớp Core chứa các thành phần cốt lõi, cấu hình và tiện ích dùng chung cho toàn bộ ứng dụng. Đây là nơi tập trung các đoạn code không thuộc về một nghiệp vụ (Domain) cụ thể nào nhưng lại cần thiết để ứng dụng có thể vận hành trơn tru.

## 2. Cấu trúc chi tiết

### 📁 `config/`
Chứa các file cấu hình hệ thống mang tính toàn cục.
- **Ví dụ thực tế**: `app_nav_items.dart` định nghĩa danh sách các menu điều hướng, icon và route tương ứng cho từng vai trò người dùng (Receptionist, Clinician, Specialist, Manager).

### 📁 `providers/`
Chứa các Riverpod providers. Đây là nơi quản lý các trạng thái toàn cục đơn giản, hỗ trợ kiến trúc Hybrid State Management.
- **Ví dụ thực tế**:
  - `auth_provider.dart`: Cung cấp trạng thái xác thực và thông tin người dùng hiện tại.
  - `header_provider.dart`: Quản lý tiêu đề (Title), phụ đề (Subtitle) và các action trên thanh AppBar một cách linh hoạt.
  - `nav_provider.dart`: Quản lý mục menu đang được chọn.

### 📁 `router/`
Quản lý luồng điều hướng của toàn bộ ứng dụng.
- **File tiêu biểu**: `app_router.dart`.
- Sử dụng thư viện `go_router` để định nghĩa cây thư mục route.
- Xử lý logic chuyển trang và phân quyền truy cập (Guard/Redirect) dựa trên trạng thái đăng nhập và Role của người dùng.

### 📁 `services/`
Chứa các dịch vụ độc lập, thực hiện các tác vụ kỹ thuật cụ thể và thường có tính chất Singleton.
- **Ví dụ thực tế**:
  - `auth_service.dart`: Xử lý logic giao tiếp với Firebase Auth.
  - `connectivity_service.dart`: Theo dõi và thông báo trạng thái kết nối mạng (Wifi/Cellular).
  - `notification_factory.dart`: Xử lý hiển thị thông báo đẩy (Push Notification) và âm thanh cảnh báo.

### 📁 Các thư mục hỗ trợ khác
- 📁 `di/`: Quản lý Dependency Injection (Sử dụng `get_it` và `injectable` để khởi tạo các service).
  > [!NOTE]
  > Chi tiết về cách hoạt động của Dependency Injection trong dự án, xem tại @doc/presentation/dependency-injection-di-trong-d-n.
- 📁 `errors/`: Định nghĩa các lỗi (Failures) và Exception chuẩn hóa để bắt lỗi nhất quán.
- 📁 `firebase/`: Các cấu hình hoặc helper riêng phục vụ cho Firebase.
- 📁 `models/`: Các Data Model mang tính toàn cục (ví dụ: định nghĩa cấu trúc `NavItem`).
- 📁 `theme/`: Định nghĩa hệ thống Design System (Màu sắc `AppColors`, Typography, Dark/Light mode).

---
Tài liệu này bổ sung chi tiết cho mục `lib/core` trong @doc/presentation/cu-trc-th-mc-lib-v-kin-trc-ng-dng.
