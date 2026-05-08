---
title: AI Chromosome App - Presentation Slide Deck Outline
description: Slide-by-slide outline and image suggestions for the AI Chromosome App presentation deck
createdAt: '2026-05-07T07:21:16.466Z'
updatedAt: '2026-05-07T07:55:13.440Z'
tags:
  - presentation
  - slide
  - outline
---

# AI Chromosome App - Presentation Slide Deck Outline

This document outlines the slide-by-slide content for presenting the AI Chromosome App, including talking points, technical highlights, and suggested visual assets for each slide.

---

## Slide 1: Title Slide
*   **Title:** AI Chromosome App
*   **Subtitle:** Streamlining Karyotyping Workflows with Artificial Intelligence
*   **Content:** Giới thiệu ngắn gọn tên dự án và nhóm thực hiện.
*   **Suggested Image:** Logo của dự án hoặc một hình ảnh minh họa (splash screen) hiện đại kết hợp giữa Y tế (chuỗi DNA/Nhiễm sắc thể) và Công nghệ (mạch điện tử/AI).

## Slide 2: Introduction & Problem Statement (Đặt vấn đề)
*   **Content:**
    *   Quy trình phân tích Karyotype thủ công hiện tại tốn nhiều thời gian (nuôi cấy, thu hoạch, đếm thủ công qua kính hiển vi) và dễ có sai sót.
    *   Hệ thống quản lý thông tin giữa Phòng khám (Clinician) và Phòng Lab (Specialist) thường rời rạc, gây chậm trễ trong việc trả kết quả cho bệnh nhân.
*   **Suggested Image:** Hình ảnh so sánh (Before/After) giữa một người đang nheo mắt nhìn kính hiển vi ghi chép sổ sách và một màn hình Dashboard hiện đại.

## Slide 3: The Solution - 6-Stage Workflow (Giải pháp)
*   **Content:** Hệ thống xây dựng một luồng nghiệp vụ khép kín (Role-based Workflow) tự động hóa quá trình luân chuyển dữ liệu:
    1.  **Receptionist:** Tạo hồ sơ bệnh nhân.
    2.  **Clinician:** Khám bệnh, tạo phiếu chỉ định (Test Order), lấy mẫu (gắn QR).
    3.  **Lab Manager:** Điều phối và giao việc cho Kỹ thuật viên.
    4.  **Specialist:** Xử lý mẫu và phân tích hình ảnh nguyên phân.
    5.  **AI Engine:** Tự động đếm và nhận diện nhiễm sắc thể.
    6.  **Approval:** Chốt kết quả ISCN và tự động xuất file PDF báo cáo.
*   **Suggested Image:** Sử dụng **Mermaid Diagram** thể hiện luồng đi qua 4 vai trò (có thể lấy từ `guides/business-workflow-and-data-flow`).

## Slide 4: High-Level System Architecture (Kiến trúc hệ thống tổng thể)
*   **Content:** Bức tranh toàn cảnh các thực thể giao tiếp với nhau:
    *   **Frontend:** Ứng dụng Flutter đa nền tảng (Web/Tablet).
    *   **Backend & Database:** Firebase (Firestore + Cloud Functions) chịu trách nhiệm lưu trữ realtime và kích hoạt các trigger tự động.
    *   **AI Server (Decoupled):** Máy chủ FastAPI/Colab độc lập chuyên xử lý mô hình AI nặng. Việc tách rời (decouple) giúp Frontend cực kỳ nhẹ và mượt mà.
*   **Suggested Image:** Sơ đồ mạng lưới (Network Diagram) với 3 cụm (Flutter <-> Firebase <-> AI Server).

## Slide 5: Flutter Clean Architecture (Kiến trúc phân tầng Ứng dụng)
*   **Content:** Cách tổ chức code nội bộ trong ứng dụng Flutter:
    *   Chia làm 4 lớp tách biệt hoàn toàn: `Core` (Cấu hình) -> `Data` (Gọi API/Firebase) -> `Domain/Logic` (Xử lý nghiệp vụ) -> `Presentation` (Giao diện).
    *   **Quy tắc thép:** Giao diện (Presentation) tuyệt đối không được gọi thẳng Database.
    *   **Data Mapping:** Phân biệt rạch ròi giữa `Model` (dùng để map JSON từ Firebase) và `Entity` (đối tượng thuần nghiệp vụ). Dữ liệu lên đến giao diện bắt buộc phải là `Entity` thông qua hàm `fromEntity`.
*   **Suggested Image:** Sơ đồ hình tròn (Onion Architecture) hoặc sơ đồ khối đi từ Data -> Domain -> Presentation.

## Slide 6: UI Component Reusability (Nghệ thuật tái sử dụng Giao diện)
*   **Content:** Các khối UI dùng chung được phân loại thành 3 nhóm chính:
    1.  **Global Shell Layout:** Dùng chung bộ khung điều hướng gồm `AppSideRail` (Collapsible sidebar, menu thay đổi theo Role) và `AppHeader` (Breadcrumbs động, Notifications).
    2.  **Dashboard Filtering System:** Bộ lọc `AppAdvancedFilterDrawer` và thanh công cụ `AppDashboardFilterBar` được inject động thông qua `drawerProvider` của Riverpod, dùng cho mọi trang danh sách.
    3.  **Design System Components:** Tái sử dụng triệt để các component nguyên tử như `DataTables`, `Status Badges` (hình viên thuốc đổi màu theo trạng thái), và hệ thống lưới 8-point grid.
*   **Suggested Image:** Minh họa dạng xếp hình (Lego blocks) cho thấy một cái khung Dashboard rỗng + các mảnh ghép Filter / Sidebar trượt vào từ bên cạnh.

## Slide 7: Hybrid State Management & UI-Data Boundary (Kiểm soát trạng thái)
*   **Content:**
    *   **Riverpod ("Data Pipe"):** Đảm nhận Dependency Injection và quản lý Global Services. Tối ưu lấy dữ liệu realtime từ Firestore (`StreamProvider`).
    *   **BLoC/Cubit ("UI Controller"):** Quản lý Business Logic từng màn hình, đóng vai trò là "chốt chặn" bảo vệ UI.
    *   **The UI-Data Boundary:** UI chỉ gửi sự kiện cho Cubit -> Cubit lấy dữ liệu (qua vòng lặp `await for`) -> Phát ra `State` -> UI dùng `BlocBuilder` để vẽ lại.
    *   **Chống nhiễu dữ liệu:** Tách riêng các State Class (vd: `AppointmentLoaded` và `RangeAppointmentsLoaded`) để các màn hình dùng chung Cubit không bị render nhầm dữ liệu của nhau.
*   **Suggested Image:** Code snippet so sánh "Before & After" (StreamBuilder vs BlocBuilder) kết hợp sơ đồ dòng chảy UI -> Cubit -> Repo -> Firebase.

## Slide 8: Highlight Feature - AI Karyotyping Workspace
*   **Content:**
    *   Trung tâm của dự án: Màn hình Workspace của Specialist.
    *   Luồng xử lý: Upload ảnh Metaphase -> Nút `Trigger AI` -> Trạng thái Processing (Loading thời gian thực) -> Trả về kết quả phân tích.
*   **Suggested Image:** Ảnh chụp màn hình thực tế của `Workspace Step 1` hiển thị trạng thái đang phân tích hoặc kết quả sau khi AI xử lý xong.

## Slide 9: Highlight Feature - Real-time Sync & Dynamic UI
*   **Content:**
    *   Hệ thống thông báo toàn cục giúp các user nhận thông báo ngay lập tức (VD: Mẫu bị hỏng, có Order mới).
    *   Dữ liệu được làm phẳng (Denormalization) hợp lý để query cực nhanh (VD: lưu kèm `patient_name` trong `test_orders` để không bị N+1 queries).
*   **Suggested Image:** Ảnh chụp màn hình thanh tìm kiếm, Sidebar Bộ lọc mở rộng hoặc dropdown Notification.

## Slide 10: Technical Challenges & Learnings (Thách thức & Giải pháp)
*   **Content:** 
    *   *Silent Loading Hangs:* Xử lý triệt để lỗi treo UI khi Firestore Stream bị lỗi (thiếu Index) bằng cách bọc `try-catch` tại lớp Repository.
    *   *Memory/State Leaks:* Quản lý chặt chẽ Lifecycle bất đồng bộ của Cubit (kiểm tra `isClosed` trước khi `emit`) để tránh crash app.
    *   *Defensive UI Layout:* Ngăn chặn lỗi màn hình đỏ (RenderFlex Overflow) trên đa thiết bị bằng pattern `LayoutBuilder` và `IntrinsicHeight`.
*   **Suggested Image:** Đoạn code snippet nhỏ minh họa cách fix lỗi Cubit hoặc icon "Bug Squashing".

## Slide 11: Conclusion & Future Work (Tổng kết & Hướng phát triển)
*   **Content:**
    *   Ứng dụng giải quyết bài toán cốt lõi của phòng Lab di truyền một cách toàn diện và tự động hóa cao.
    *   Khả năng mở rộng (Future Work): Train thêm AI cho các loại mẫu khác, tích hợp sâu hơn với hệ thống HIS (Hospital Information System) của bệnh viện.
*   **Suggested Image:** Hình ảnh tập thể nhóm (Team Photo) hoặc một Graphic mô tả định hướng tương lai.

---
*Created via `kn-doc` presentation research extraction.*
