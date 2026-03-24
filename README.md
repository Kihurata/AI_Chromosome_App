# MedCore Hospital CRM

Hệ thống quản lý phòng khám chuyên nghiệp (Hospital CRM) với tính năng hỗ trợ Bác sĩ phân tích và điều trị y tế tiên tiến.

Đây là ứng dụng đa nền tảng (Cross-platform) xây dựng bằng **Flutter**, nhắm mục tiêu triển khai dưới dạng **Web App** và **Desktop App**.

## 🛠 Tech Stack (Công nghệ sử dụng)
* **Framework:** Flutter 3.x
* **Global State & API Binding:** [Riverpod](https://riverpod.dev/) (Quản lý User Role, Stream Real-time)
* **Local UI State:** [BLoC / Cubit](https://bloclibrary.dev/) (Dùng cho các tính năng phức tạp như màn hình kéo thả Karyotype)
* **UI & Theming:** Tùy biến chuẩn theo Design System nội bộ `docs/UI_DESIGN_SYSTEM.md` sử dụng `lucide_icons` và `google_fonts` (Inter).

---

## 🚀 Hướng dẫn cài đặt & Chạy ứng dụng

Nếu bạn vừa clone repository này về cấu hình máy mới, hãy làm theo các bước dưới đây để khởi chạy và đóng góp.

### Yêu cầu hệ thống (Prerequisites)
- Cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install) (Khuyến nghị phiên bản 3.x trở lên).
- Đảm bảo máy tính đã kích hoạt hỗ trợ Web/Desktop. Bạn có thể kiểm tra danh sách máy ảo/trình duyệt khả dụng bằng cách gõ dòng lệnh: `flutter doctor`

### Bước 1: Cài đặt Package & Dependency
Sau khi tải source code về, khởi chạy Terminal/Command Prompt trực tiếp tại thư mục dự án và tải các thư viện:

```bash
flutter pub get
```

### Bước 2: Build & Chạy thử

Bạn có thể chạy thẳng ứng dụng (Dev Mode) lên Chrome hoặc build nó dưới một app Desktop chạy độc lập:

**💻 Chạy trên trình duyệt Web (Rất tiện lợi để debug Dashboard):**
```bash
flutter run -d chrome
```

**🪟 Chạy Native Desktop cho Windows:**
```bash
flutter run -d windows
```

**🍎 Chạy Native Desktop cho macOS:**
```bash
flutter run -d macos
```

---

## 🧩 Cấu trúc thư mục (Project Structure)
Các file mã nguồn nằm trong thư mục `/lib`. Hệ thống tuân theo Design Pattern Clean kết hợp state-driven.
```text
lib/
├── core/                # Các thành phần cốt lõi: Theme (màu/font), Error Handling, Utils...
├── presentation/        # Tầng giao diện và Logic hiển thị nội tại UI
│   ├── pages/           # Code giao diện chung từng màn hình (Ví dụ: Dashboard chuyên gia)
│   └── widgets/         # Component UI bóc tách, module tái sử dụng (Header chức năng, Sidebar, Data Table,...)
└── main.dart            # Nơi Bootstrap App (Kết nối ProviderScope cho Riverpod)
```

---

## 📝 Check-list khi viết Code (For Team Members)
1. **Thiết kế UI:** Tuyệt đối giữ đúng màu sắc (Primary Blue `0xFF0D6EFD`, Border `0xFFE9ECEF`...) và icon line (stroke mỏng 2px) được quy chuẩn trong `docs/UI_DESIGN_SYSTEM.md`. Không nên tự ý chèn thêm thư viện Component UI đóng gói sẵn phá vỡ kiến trúc thuần tuý.
2. **Cập nhật mã:** Hãy tạo nhánh riêng `feature/...` thay vì đẩy code thẳng lên nhánh chính.
3. **Phân luồng Quản lý Trạng thái:** Nếu dữ liệu đến từ Database Server cần hiển thị tức thời -> dùng Riverpod. Nếu là một luồng (flow) nhập liệu/kéo thả tại chỗ tốn bộ nhớ -> dùng Cubit. 
4. **Quy tắc Kiểm tra lỗi Code:** Trước khi Push hoặc Submit Code, VUI LÒNG gõ qua lệnh xác minh chuẩn syntax sau để đảm bảo không dính file rác:
   ```bash
   flutter analyze
   ```
