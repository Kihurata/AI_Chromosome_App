---
title: Cấu trúc thư mục lib và Kiến trúc ứng dụng
description: Tài liệu chi tiết về cấu trúc thư mục lib, vai trò của từng file/folder và mô hình Clean Architecture kết hợp Hybrid State Management.
createdAt: '2026-05-13T07:43:46.970Z'
updatedAt: '2026-05-14T07:17:16.683Z'
tags:
  - architecture
  - folder-structure
  - clean-architecture
  - flutter
---

# Cấu trúc thư mục `lib` và Kiến trúc ứng dụng

## 1. Tổng quan kiến trúc
Dự án được xây dựng theo mô hình **Clean Architecture** kết hợp với **Hybrid State Management** (Riverpod + BLoC/Cubit).
- **Riverpod**: Được sử dụng để quản lý các luồng dữ liệu (Data Streams từ Firestore) và cung cấp các trạng thái toàn cục một cách trực quan.
- **BLoC/Cubit**: Được sử dụng để xử lý logic nghiệp vụ và các tương tác phức tạp của người dùng trong các module cụ thể.

## 2. Chi tiết cấu trúc thư mục `lib`

Thư mục `lib` được chia thành 5 thư mục con chính đại diện cho các lớp kiến trúc và mục đích sử dụng:

### 📁 `lib/core`
Chứa các thành phần cốt lõi, cấu hình và tiện ích dùng chung cho toàn bộ ứng dụng. Đây là nơi chứa code không thuộc về một nghiệp vụ cụ thể nào nhưng cần thiết cho toàn bộ app.
- 📁 `config/`: Cấu hình hệ thống (ví dụ: danh sách menu điều hướng trong `app_nav_items.dart`).
- 📁 `di/`: Quản lý Dependency Injection (Sử dụng `get_it` và `injectable`).
- 📁 `errors/`: Định nghĩa các lỗi (Failures) và Exception chuẩn hóa.
- 📁 `firebase/`: Các cấu hình hoặc helper riêng cho Firebase.
- 📁 `models/`: Các Data Model mang tính toàn cục (ví dụ: định nghĩa Role trong `nav_item.dart`).
- 📁 `network/`: Các tiện ích xử lý kết nối mạng.
- 📁 `providers/`: Các Riverpod providers (ví dụ: `header_provider.dart` quản lý tiêu đề AppBar, hoặc các provider dùng để bắc cầu từ BLoC sang Riverpod).
- 📁 `router/`: Cấu hình định tuyến cho ứng dụng (Sử dụng `go_router`).
- 📁 `services/`: Các dịch vụ độc lập như `AuthService` (xác thực) hoặc `NotificationFactory` (hiển thị thông báo).
- 📁 `theme/`: Định nghĩa hệ thống Design System (Màu sắc, Typography, Dark/Light mode).

> [!NOTE]
> Chi tiết về các file và thư mục con trong lớp Core, xem tại @doc/presentation/chi-tit-lp-core-libcore.

### 📁 `lib/data`
Lớp Dữ liệu (Data Layer) trong Clean Architecture. Chịu trách nhiệm giao tiếp với thế giới bên ngoài (APIs, Firebase Firestore).
- Chứa các Data Source (đọc/ghi dữ liệu thô).
- Chứa các Repository Implementation (triển khai cụ thể các interface từ lớp Domain).
- Chuyển đổi dữ liệu thô (JSON, DocumentSnapshot) thành các Model trong ứng dụng.

> [!NOTE]
> Chi tiết về các file và thư mục con trong lớp Data, xem tại @doc/presentation/chi-tit-lp-data-libdata.

### 📁 `lib/domain`
Lớp Nghiệp vụ (Domain Layer). Chứa các quy tắc nghiệp vụ thuần túy (Pure Dart), không phụ thuộc vào Flutter hay bất kỳ thư viện bên ngoài nào.
- Chứa các Entity (Thực thể dữ liệu cốt lõi).
- Chứa các Abstract Repository (Interface định nghĩa các hành động lấy dữ liệu).

> [!NOTE]
> Chi tiết về các file và thư mục con trong lớp Domain, xem tại @doc/presentation/chi-tit-lp-domain-libdomain.

### 📁 `lib/logic`
Nơi chứa logic điều khiển trạng thái ứng dụng. Dự án sử dụng mô hình BLoC/Cubit ở đây.
- 📁 `bloc/`: Chứa các thư mục con cho từng tính năng lớn (ví dụ: `auth/` cho xác thực, `notification/` cho thông báo). Mỗi thư mục thường có cặp file `..._cubit.dart` và `..._state.dart`.

> [!NOTE]
> Chi tiết về các file và thư mục con trong lớp Logic, xem tại @doc/presentation/chi-tit-lp-logic-liblogic.

### 📁 `lib/presentation`
Lớp Giao diện (Presentation Layer). Chứa toàn bộ mã nguồn liên quan đến hiển thị UI và tương tác người dùng.
- 📁 `screens/`: Các màn hình hoàn chỉnh, thường được chia theo vai trò người dùng (Role) như `receptionist/`, `clinician/`, `specialist/` hoặc theo module như `auth/`.
- 📁 `widgets/`: Các thành phần giao diện nhỏ hơn, có thể tái sử dụng. Được chia thành `shared/` (dùng chung) hoặc nằm trong thư mục của từng role cụ thể.

> [!NOTE]
> Chi tiết về các thành phần giao diện trong lớp Presentation, xem tại @doc/presentation/chi-tit-lp-presentation-libpresentation.

### 📄 `lib/main.dart`
Điểm khởi chạy (Entry Point) của ứng dụng Flutter. Thực hiện khởi tạo Firebase, thiết lập Dependency Injection và chạy widget gốc.

---

## 3. Các quy tắc phát triển quan trọng (Conventions)
1. **Không import Firestore vào Presentation**: Tuyệt đối không gọi trực tiếp Firestore trong các file thuộc `presentation/`. Mọi dữ liệu phải đi qua Cubit hoặc Riverpod.
2. **Sự kết hợp giữa Cubit và Riverpod**: Cubit xử lý hành động (Action/Event), trong khi Riverpod lắng nghe dữ liệu thời gian thực (Stream) từ Firestore để đẩy về UI.

## 4. Quy trình phát triển tính năng mới
Để biết chi tiết từng bước triển khai một tính năng mới (tạo file nào trước, file nào sau), xem tại @doc/presentation/quy-trnh-trin-khai-tnh-nng-mi-step-by-step.
