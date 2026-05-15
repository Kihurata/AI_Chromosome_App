---
title: Cơ chế hoạt động của chức năng Auth và Role
description: Tài liệu chi tiết về cơ chế xác thực, phân quyền và cách xử lý lỗi Race Condition trên F5 trong hệ thống Auth.
createdAt: '2026-05-13T07:34:57.358Z'
updatedAt: '2026-05-13T07:35:10.281Z'
tags:
  - auth
  - role
  - race-condition
  - firebase
---

# Cơ chế hoạt động của chức năng Auth và Role

## 1. Tổng quan
Hệ thống sử dụng Firebase Auth để xác thực người dùng và Firestore để lưu trữ thông tin phân quyền (Role) trong collection `users`.

Quá trình xác thực và phân quyền được quản lý chủ yếu bởi hai Cubit:
- **`AuthCubit`**: Quản lý trạng thái đăng nhập và xác định Role của người dùng để điều hướng UI.
- **`NotificationCubit`**: Quản lý việc đăng ký và cập nhật FCM Token cho thông báo đẩy.

## 2. Luồng xử lý khi Khởi động / F5 (Page Refresh)
Khi ứng dụng khởi động hoặc người dùng nhấn F5, cả hai Cubit đều lắng nghe luồng sự kiện `authStateChanges()` từ Firebase Auth:

### Luồng xử lý của `AuthCubit`:
1. Nhận thông tin `User` từ Firebase Auth.
2. Thực hiện truy vấn Firestore để lấy document của người dùng: `FirebaseFirestore.instance.collection('users').doc(user.uid)`.
3. **Quan trọng**: Sử dụng `GetOptions(source: Source.server)` để bắt buộc đọc từ server, tránh việc lấy dữ liệu cũ từ cache.
4. Đọc trường `role` từ document.
   - Nếu trường `role` không tồn tại, mặc định gán là `'user'`.
5. Gọi `AppRole.fromString(role)` để map chuỗi string thành Enum `AppRole`.
6. Phát ra trạng thái `Authenticated(user, role)` để UI vẽ lại menu theo quyền.

### Luồng xử lý của `NotificationCubit`:
1. Nhận thông tin `User` từ Firebase Auth.
2. Lấy FCM Token từ thiết bị.
3. Cập nhật FCM Token vào Firestore document của user.

---

## 3. Vấn đề Race Condition trên F5 & Cách xử lý (Đã Fix)

### Triệu chứng trước đây
Người dùng đang ở các Role như `Specialist` hoặc `Clinician`, sau khi nhấn F5 thì giao diện tự động nhảy về Role `Receptionist` (Lễ tân).

### Nguyên nhân gốc rễ
Do cả hai Cubit cùng chạy đồng thời trên F5:
1. `NotificationCubit` chạy trước và thực hiện lệnh: `.set({'fcm_token': token}, SetOptions(merge: true))`.
2. Nếu tại thời điểm F5, cache của trình duyệt bị trống (hoặc chưa kịp load), lệnh `set(merge: true)` này sẽ tạo ra một document "ảo" trong cache chỉ có DUY NHẤT trường `fcm_token`.
3. Ngay sau đó, `AuthCubit` thực hiện đọc document. Do cơ chế tối ưu của Firestore, nó có thể đọc trúng dữ liệu "ảo" vừa được tạo trong cache (hoặc đang chờ sync lên server).
4. `AuthCubit` thấy document không có trường `role` -> Fallback về `'user'`.
5. Trong file `nav_item.dart`, hàm `AppRole.fromString('user')` không tìm thấy enum nào khớp nên đã fallback mặc định về `AppRole.receptionist`.

### Giải pháp đã áp dụng (Approach A)
Thay đổi cách cập nhật token trong `NotificationCubit` từ `set(merge: true)` sang **`update()`**:

```dart
// Code mới trong NotificationCubit
await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .update({'fcm_token': token});
```

**Lợi ích:**
- Lệnh `update()` chỉ cập nhật các trường được chỉ định trên một document **đã tồn tại**.
- Nếu document chưa tồn tại trên server/cache, nó sẽ ném ra lỗi `FirebaseException` với code `not-found` thay vì tự động tạo một document mới bị thiếu trường.
- Code đã được bọc trong `try-catch` để bắt riêng mã lỗi `not-found` và bỏ qua một cách an toàn. Nhờ đó, hiện tượng tạo document "rác" gây mất Role đã được triệt tiêu.

## 4. Quy tắc Ánh xạ Role (Role Mapping)
Việc ánh xạ từ chuỗi trong DB sang Enum trong code được thực hiện tại `lib/core/models/nav_item.dart`:

- `doctor` -> `AppRole.clinician`
- `admin` -> `AppRole.manager`
- Các chuỗi khác (ví dụ: `receptionist`, `specialist`) -> Khớp trực tiếp với tên Enum.
- Bất kỳ chuỗi nào không khớp -> Mặc định rơi vào `AppRole.receptionist`.

> [!WARNING]
> Cần cẩn trọng khi thay đổi giá trị fallback trong `AppRole.fromString` vì nó ảnh hưởng đến quyền mặc định của người dùng khi hệ thống gặp lỗi dữ liệu.
