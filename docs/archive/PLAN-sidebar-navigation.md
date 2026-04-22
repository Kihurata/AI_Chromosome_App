# Kế hoạch Thiết kế lại Navigation & Sidebar (Data-Driven UI)

## 📌 Tổng quan Task
Cấu trúc lại hệ thống Navigation và Sidebar của ứng dụng thành Data-Driven UI, sử dụng Flutter's `NavigationRail` kết hợp `LayoutBuilder` cho Responsive (Mobile tự động chuyển Drawer/BottomNav). Bảo mật truy cập bằng Global Redirect của `GoRouter` tích hợp với hệ thống State Management `Riverpod`.

## 🧑‍💻 Roles hệ thống (Tra cứu từ bảng `users`)
- `manager`: Quản lý
- `clinician`: Bác sĩ lâm sàng
- `specialist`: Bác sĩ lab (di truyền học xử lý AI)
- `receptionist`: Lễ tân

---

## 🛠 Giải pháp kỹ thuật (Solutioning)

### 1. Data-Driven Model (`NavItem`)
Định nghĩa một class `NavItem` làm nguồn dữ liệu duy nhất (Single Source of Truth) cho việc hiển thị menu:
```dart
class NavItem {
  final String label;
  final IconData icon;
  final String routePath;
  final List<AppRole> allowedRoles; // Các Roles được phép thấy/truy cập
  
  const NavItem({...});
}
```

### 2. Global Menu List
Tạo một file chứa toàn bộ danh sách `appMenuItems`. Dựa trên danh sách này, các UI thành phần sẽ map() ra các `NavigationRailDestination` hoặc `BottomNavigationBarItem` một cách tự động.

### 3. State Management (Riverpod) Filter
Tạo Provider `filteredNavItemsProvider`:
- Provider này lấy Authentication State (chứa user role) từ hệ thống.
- Filter `appMenuItems` thành danh sách chỉ chứa những item mà Role hiện tại (VD: `receptionist`) có quyền (trong list `allowedRoles`).
- UI Sidebar chỉ việc lắng nghe Provider này để render, loại bỏ hoàn toàn các câu lệnh if-else rối rắm trên views.

### 4. Responsive Wrapper (`AppNavigationWrapper`)
Tạo một Layout bao bọc toàn bộ App:
- Sử dụng `LayoutBuilder` để đọc chiều rộng màn hình.
- `if (maxWidth >= 800)` (Tablet/Desktop): 
  - Render `Scaffold` với `body: Row(children: [NavigationRail, Expanded(child: page)])`.
- `else` (Mobile): 
  - Render `Scaffold` với `body: page`, `bottomNavigationBar: BottomNavigationBar(...)` hoặc `drawer: Drawer(...)`.

### 5. GoRouter Global Redirect Security
Bảo mật ở cấp độ Core Navigation (tránh user gõ URL truy cập trái phép web). Trong `GoRouter` config định nghĩa một hàm `redirect`:
- Đọc Auth State và Role hiện hành.
- Check Route chuẩn bị truy cập (xác định mục tiêu `matchedLocation`).
- Đối chiếu với `appMenuItems` -> Nếu tìm thấy route mà Role hiện hành không có trong `allowedRoles` -> Return redirect URL (ví dụ `/403` hoặc `/home`).

---

## 📋 Task Breakdown (Các bước thực hiện - Không vượt qua bước này nếu chưa chốt code)

- [ ] **Task 1:** Tạo model `NavItem.dart` và enum `AppRole.dart` (nếu chưa có chuẩn).
- [ ] **Task 2:** Định nghĩa danh sách `appConfigMenuItems` ở một file constants.
- [ ] **Task 3:** Viết `filteredNavItemsProvider` (Riverpod) để lọc menu theo User Mode.
- [ ] **Task 4:** Xây dựng `AppNavigationWrapper` (Responsive UI bằng LayoutBuilder).
- [ ] **Task 5:** App dụng `AppNavigationWrapper` như một cấu hình `ShellRoute` trong `GoRouter`.
- [ ] **Task 6:** Viết logic Global Redirect cho `GoRouter` dựa trên AuthState và danh sách allowedRoles.
- [ ] **Task 7:** Thay thế màn hình cũ (`receptionist_sidebar.dart` & `app_sidebar.dart`) bằng Wrapper mới.

---

## 🚦 Phân công Agent
- **@frontend-specialist**: Chịu trách nhiệm thiết kế hệ thống layout `AppNavigationWrapper`, `NavigationRail` và `BottomNavBar`, UX/UI chuyển đổi mượt mà. Đảm bảo tuân thủ màu sắc và material design 3.
- **@orchestrator / @backend-specialist**: Chịu trách nhiệm review hệ thống Route, GoRouter Redirection và Riverpod integration để đảm bảo role access hoàn toàn bảo mật.

---

*Lưu ý: Không viết code nào ngoài file markdown này khi đang trong chế độ `-plan`.*
