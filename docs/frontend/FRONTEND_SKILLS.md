# MedCore Frontend AI Skills (Cheat Sheet)

Tài liệu này là "bộ nhớ tối ưu" dành cho AI. Khi AI lập trình Frontend cho dự án này, **BẮT BUỘC** phải tuân thủ các quy tắc sau để giữ kiến trúc Clean Architecture và đồng bộ UI Design.

## 1. UI Components & Layouts (Bắt Buộc Dùng)
Thay vì tự code UI từ đầu, hãy sử dụng các Global Widgets đã được tạo sẵn trong `lib/presentation/widgets/shared/`:

*   **Trang Danh sách / Dashboard:** Bọc toàn bộ nội dung trong `MainListLayout`. Nó đã có sẵn Header và Title.
*   **Trang Điền Form:** Bọc toàn bộ nội dung trong `MainFormLayout`.
*   **Bảng Dữ Liệu (Table):** KHÔNG tự dùng `DataTable` thuần. Hãy dùng `AppDataTable` (hỗ trợ bo góc, shadow, phân trang và search).
*   **Nút Bấm (Button):** Dùng `AppPrimaryButton` (nút chính, màu xanh) và `AppSecondaryButton` (nút phụ, viền mờ). KHÔNG dùng `ElevatedButton` hay `FilledButton` thuần.
*   **Ô Nhập Liệu (Input):** Dùng `AppTextField`. Nó đã cấu hình sẵn padding, border color và error style theo thiết kế.

## 2. Kiến Trúc & State Management
*   **Tách Biệt Logic:** Tuyệt đối KHÔNG import `cloud_firestore` hoặc gọi trực tiếp API bên trong các file giao diện (UI/Screen).
*   **Routing:** Ứng dụng dùng `GoRouter`. Cấu trúc shell (có Sidebar) đã được bọc bằng `AppNavigationWrapper`. Khi thêm trang mới, chỉ cần khai báo đường dẫn trong `lib/core/router/app_router.dart` và nằm trong `ShellRoute`.
*   **State Management:**
    *   Sử dụng `Riverpod` (`ref.watch`) cho State Toàn Cục (Ví dụ: `AuthNotifier` để lấy Role và thông tin User).
    *   Sử dụng `flutter_bloc` (`Cubit`/`Bloc`) cho State Cục Bộ (Nghiệp vụ từng trang).

## 3. Quy Tắc Mock Data (Giai đoạn chưa có API)
*   Nếu chức năng được yêu cầu chưa có API Backend:
    1. Tạo hàm trong lớp Repository (`lib/data/repositories/`).
    2. Dùng `Future.delayed` để trả về danh sách/object giả (Mock Data) theo đúng chuẩn Model.
    3. UI và Bloc vẫn gọi qua Repository như bình thường. Khi có API thật, chỉ cần sửa logic trong Repository, không cần đụng đến UI.
