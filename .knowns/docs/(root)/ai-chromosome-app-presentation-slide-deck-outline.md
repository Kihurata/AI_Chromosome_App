---
title: AI Chromosome App - Presentation Slide Deck Outline
description: Slide-by-slide outline and image suggestions for the AI Chromosome App presentation deck
createdAt: '2026-05-07T07:21:16.466Z'
updatedAt: '2026-05-07T07:21:16.466Z'
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

## Slide 4: System Architecture & Tech Stack (Kiến trúc & Công nghệ)
*   **Content:**
    *   **Frontend:** Flutter (Hỗ trợ đa nền tảng Web/Tablet). Áp dụng **Clean Architecture** nghiêm ngặt.
    *   **State Management:** Hybrid (Riverpod cho Global Services/DI + BLoC/Cubit cho Feature Business Logic).
    *   **Backend & DB:** Firebase (Firestore) kết hợp Cloud Functions.
    *   **AI Server:** Kiến trúc Decoupled chạy trên FastAPI/Colab (thông qua Ngrok) để giảm tải cho Frontend.
*   **Suggested Image:** Sơ đồ kiến trúc hệ thống (System Architecture Diagram) mô tả các node: App UI <-> Firestore <-> Cloud Functions <-> FastAPI Server.

## Slide 5: Highlight Feature - AI Karyotyping Workspace
*   **Content:**
    *   Trung tâm của dự án: Màn hình Workspace của Specialist.
    *   Luồng xử lý: Upload ảnh Metaphase -> Nút `Trigger AI` -> Trạng thái Processing (Loading thời gian thực) -> Trả về kết quả phân tích.
*   **Suggested Image:** Ảnh chụp màn hình (Screenshot) thực tế của `Workspace Step 1` hiển thị các ảnh đang ở trạng thái loading (spinner/lottie) hoặc ảnh kết quả sau khi AI xử lý xong.

## Slide 6: Highlight Feature - Real-time Sync & Dynamic UI
*   **Content:**
    *   Hệ thống thông báo toàn cục (Global Notification System) giúp các vai trò nhận thông báo ngay lập tức khi có sự kiện (VD: Mẫu bị hỏng, có Order mới).
    *   Hệ thống Filter động (Advanced Filter Drawer) được chuẩn hóa và tái sử dụng trên mọi trang Dashboard.
*   **Suggested Image:** Ảnh chụp màn hình thanh công cụ tìm kiếm (Dashboard Filter Bar) và Sidebar Bộ lọc mở rộng (Advanced Filter Drawer) của ứng dụng. Hoặc ảnh chụp dropdown Notification.

## Slide 7: Technical Challenges & Learnings (Thách thức & Giải pháp)
*   **Content:** 
    *   *Silent Loading Hangs:* Xử lý triệt để lỗi treo UI khi Firestore Stream bị lỗi (thiếu Index) bằng cách bọc `try-catch` tại lớp Repository.
    *   *Memory/State Leaks:* Quản lý chặt chẽ Lifecycle bất đồng bộ của Cubit (kiểm tra `isClosed` trước khi `emit`) để tránh crash app khi user chuyển trang nhanh.
    *   *Defensive UI Layout:* Ngăn chặn lỗi màn hình đỏ (RenderFlex Overflow) trên đa thiết bị bằng pattern kết hợp `LayoutBuilder` và `IntrinsicHeight`.
*   **Suggested Image:** Đoạn code snippet nhỏ (Before/After) minh họa cách fix lỗi Cubit hoặc một icon "Bug Squashing" kết hợp biểu tượng Performance.

## Slide 8: Conclusion & Future Work (Tổng kết & Hướng phát triển)
*   **Content:**
    *   Ứng dụng giải quyết bài toán cốt lõi của phòng Lab di truyền một cách toàn diện và tự động hóa cao.
    *   Khả năng mở rộng (Future Work): Train thêm mô hình AI cho các loại mẫu khác, tích hợp sâu hơn với hệ thống HIS (Hospital Information System) hiện tại.
*   **Suggested Image:** Hình ảnh tập thể nhóm (Team Photo) hoặc một Graphic mô tả định hướng tương lai (Mũi tên vút lên / Trái đất kết nối số).

---
*Created via `kn-doc` presentation research extraction.*
