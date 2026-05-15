---
title: Chi tiết lớp Logic (lib/logic)
description: Tài liệu chi tiết về lớp Logic (lib/logic), bao gồm các BLoC/Cubit quản lý state.
createdAt: '2026-05-13T07:54:31.088Z'
updatedAt: '2026-05-13T08:12:45.137Z'
tags:
  - architecture
  - logic-layer
  - bloc
  - cubit
---

# Chi tiết lớp Logic (`lib/logic`)

## 1. Vai trò
Lớp Logic chịu trách nhiệm quản lý trạng thái (State Management) và điều khiển luồng hoạt động của ứng dụng. Nó nhận các sự kiện hoặc yêu cầu từ lớp UI, gọi đến các Use Case ở lớp Domain để xử lý nghiệp vụ, và phát ra (emit) các trạng thái mới để UI vẽ lại.

Dự án sử dụng thư viện `flutter_bloc` với mô hình **Cubit** (một biến thể đơn giản hóa của BLoC) để quản lý state cho hầu hết các tính năng.

## 2. Kiến thức cơ bản

### 💡 State Management là gì?
Trong Flutter, **State** (Trạng thái) là bất kỳ dữ liệu nào có thể thay đổi trong suốt vòng đời của ứng dụng và ảnh hưởng trực tiếp đến những gì hiển thị trên màn hình (UI).
**State Management** (Quản lý trạng thái) là quá trình:
1. **Lưu trữ** dữ liệu của ứng dụng ở một nơi an toàn.
2. **Cập nhật** dữ liệu đó khi có sự kiện xảy ra (Người dùng bấm nút, Dữ liệu từ API trả về).
3. **Thông báo** cho UI biết để tự động vẽ lại (Rebuild) những phần màn hình bị ảnh hưởng.

Nếu không có State Management, việc truyền dữ liệu giữa các màn hình sẽ rất phức tạp (Callback hell) và giao diện sẽ không tự động cập nhật khi dữ liệu thay đổi.

### 💡 Cubit là gì?
**Cubit** là một giải pháp quản lý trạng thái thuộc thư viện `flutter_bloc`. Nó là một phiên bản rút gọn và đơn giản hơn của BLoC (Business Logic Component).
- Trong BLoC truyền thống: UI gửi **Event** vào BLoC -> BLoC xử lý -> Phát ra **State**.
- Trong Cubit: UI gọi trực tiếp các **Hàm (Method)** trong Cubit -> Cubit xử lý -> Phát ra **State**.
Cubit giúp code ngắn gọn, dễ đọc và giảm thiểu lượng code mẫu (Boilerplate) phải viết.

### 💡 Tại sao luôn luôn cần 2 file: `..._cubit.dart` và `..._state.dart`?
Đây là quy tắc bắt buộc của thư viện Bloc/Cubit nhằm tuân thủ nguyên lý **Tách biệt mối quan tâm (Separation of Concerns)**:

1. **File `..._state.dart` (Dữ liệu hiển thị - Cái gì?)**:
   - File này **chỉ định nghĩa cấu trúc dữ liệu** mà giao diện cần để hiển thị.
   - Nó trả lời cho câu hỏi: "Hiện tại màn hình đang ở trạng thái nào?". Ví dụ: Đang tải (`Loading`), Tải thành công (`Success`), hoặc Bị lỗi (`Error`).
   - Tuyệt đối không chứa logic xử lý ở đây.

2. **File `..._cubit.dart` (Logic xử lý - Làm như thế nào?)**:
   - File này chứa các **hàm xử lý logic nghiệp vụ**.
   - Nó nhận lệnh từ UI, xử lý (ví dụ: gọi API), và sau đó phát ra trạng thái mới bằng lệnh `emit(NewState)`.

**Lợi ích của việc tách đôi này:**
- **Dễ bảo trì**: UI chỉ cần quan tâm đến State để vẽ giao diện. Logic nằm gọn trong Cubit.
- **Dễ Unit Test**: Có thể dễ dàng viết test để kiểm tra: "Khi gọi hàm A trong Cubit thì Cubit có phát ra State B hay không".

## 3. Cấu trúc chi tiết trong dự án

### 📁 `bloc/`
Thư mục này chứa tất cả các Cubit của ứng dụng, được chia nhỏ theo từng module hoặc tính năng. Mỗi thư mục con chứa cặp file Cubit và State như đã giải thích ở trên.

**Các Cubit tiêu biểu trong dự án:**
- 📁 `auth/`: Quản lý trạng thái đăng nhập, đăng xuất và phân quyền (`AuthCubit`).
- 📁 `notification/`: Quản lý nhận thông báo đẩy và phát âm thanh cảnh báo (`NotificationCubit`).
- 📁 `workspace/`: Quản lý luồng làm việc 3 bước của Specialist (`WorkspaceCubit`).
- 📁 `manager/`, `clinician/`, `specialist/`: Quản lý logic màn hình Dashboard cho từng vai trò tương ứng.
- 📁 `connectivity/`: Theo dõi trạng thái kết nối mạng (Internet).
- 📁 `layout/`: Quản lý trạng thái giao diện (ví dụ: đóng/mở thanh Sidebar).

## 4. Mô hình Hybrid State Management (Cubit + Riverpod)
Mặc dù logic hành động nằm ở Cubit, dự án áp dụng mô hình Hybrid rất đặc biệt:
- **Cubit** dùng cho các hành động mang tính chất **Command/Event** (Ví dụ: Người dùng bấm nút Login, Gửi form, Chuyển tab).
- **Riverpod** dùng cho các dữ liệu mang tính chất **Stream/Cache** (Ví dụ: Lắng nghe danh sách bệnh nhân thời gian thực từ Firestore).
- Cách tiếp cận này giúp tận dụng thế mạnh của cả hai: Cubit giữ cho luồng logic tuần tự và dễ hiểu, trong khi Riverpod xử lý bất đồng bộ và auto-dispose cực tốt.

---
Tài liệu này bổ sung chi tiết cho mục `lib/logic` trong @doc/presentation/cu-trc-th-mc-lib-v-kin-trc-ng-dng.
