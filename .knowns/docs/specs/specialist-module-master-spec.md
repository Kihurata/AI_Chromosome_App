---
title: Specialist Module (Master Spec)
description: Comprehensive specification for the Lab Specialist role, including Dashboard, AI Workspace, and supporting features.
createdAt: '2026-04-29T18:21:48.261Z'
updatedAt: '2026-04-29T18:21:48.261Z'
tags:
  - spec
  - draft
  - specialist
---

## Overview
Tài liệu này đặc tả toàn bộ chức năng dành cho vai trò **Lab Specialist** trong hệ thống AI Chromosome. Specialist chịu trách nhiệm quản lý danh sách phiếu xét nghiệm, thực hiện phân tích NST đồ (Karyotyping) với sự hỗ trợ của AI, và lập báo cáo chẩn đoán cuối cùng.

## Locked Decisions
- **D1 (Linear Workspace):** Quy trình Workspace gồm 5 bước tuyến tính: Sàng lọc -> Tách NST -> Lập NST đồ -> Chẩn đoán -> Lập báo cáo.
- **D2 (Hybrid Sync):** Workspace Bước 2 (Tách) dùng Local State; Bước 3 (Karyotype) dùng Auto-save (Debounce 1.5s).
- **D3 (AI Orchestration):** AI chạy bất đồng bộ (Fire & Forget). UI hiển thị thanh Progress chung (D7) và trạng thái ngoài Dashboard (D3).
- **D4 (Data Integrity):** Chuyển đổi tọa độ Polygon sang ảnh PNG thực tế trên Backend (D4) để tiết kiệm RAM thiết bị di động.
- **D5 (Role Boundaries):** Specialist chỉ thấy các phiếu được Manager phân công trực tiếp cho mình (thông qua FCM Notifications - D8).
- **D6 (Low-Priority Extras):** Các chức năng xem lịch sử (Archive) và lý do từ chối (Rejection Comments) được thiết kế dạng placeholder/cơ bản trong giai đoạn này.

## Requirements

### 1. Dashboard (Quản lý công việc)
- **FR-1.1 (Statistics):** Hiển thị Bento Box với 4 chỉ số: Chờ xử lý, Đang phân tích, Chờ duyệt, Hoàn thành.
- **FR-1.2 (Order List):** Danh sách Test Orders hiển thị theo thời gian thực (Firestore Stream).
- **FR-1.3 (Notification Interaction):** Khi bấm vào thông báo "Ca mới được phân công", app điều hướng thẳng tới chi tiết phiếu đó trên Dashboard.
- **FR-1.4 (Search & Filter):** Tìm kiếm theo tên/mã bệnh nhân và lọc theo trạng thái (Waiting, Analyzing, Pending Approval).

### 2. Workspace (Quy trình phân tích 5 bước)
- **FR-2.1 (Step 1 - Selection):** Chọn 1-3 ảnh Metaphase tốt nhất từ tập ảnh thô.
- **FR-2.2 (Step 2 - Slicing):** Công cụ Lasso/Crop để tách các NST bị dính. Backend trả về danh sách chromosome images riêng lẻ.
- **FR-2.3 (Step 3 - Karyotyping):** Kéo thả NST vào lưới 23 cặp (22 tự thể + 1 giới tính). Hỗ trợ xoay ảnh NST.
- **FR-2.4 (Step 4 - Diagnosis):** Nhập ISCN Formula (ví dụ: 46,XX) và nhận xét lâm sàng sơ bộ.
- **FR-2.5 (Step 5 - Final Report):** Tổng hợp dữ liệu thành báo cáo mẫu và nút "Submit for Approval".

### 3. Supporting Features
- **FR-3.1 (Rejection View):** Nếu phiếu bị từ chối, hiển thị badge "Rejected" và khung text chứa lý do từ Manager (Priority: Low).
- **FR-3.2 (History Archive):** Tab phụ hoặc filter để xem lại các phiếu đã `COMPLETED` (Priority: Low).

## Acceptance Criteria
- [ ] **AC-1:** Dashboard cập nhật stats ngay khi Firestore thay đổi (Manager phân công hoặc AI xong).
- [ ] **AC-2:** Workspace block việc "Next Step" nếu dữ liệu bắt buộc của bước hiện tại chưa hoàn thành.
- [ ] **AC-3:** Ở Bước 3, vị trí NST được lưu lại chính xác sau khi app bị restart (thông qua Firestore persistence).
- [ ] **AC-4:** Bấm "Submit for Approval" sẽ chuyển trạng thái Test Order sang `PENDING_APPROVAL` và ẩn phiếu khỏi danh sách làm việc chính.
- [ ] **AC-5:** Thông báo FCM hiện đúng thông tin ca bệnh và Specialist nhận được click điều hướng thành công.

## Technical Notes
- **State Management:** Sử dụng `SpecialistDashboardCubit` cho Dashboard và `WorkspaceCubit` riêng cho luồng 5 bước để tránh rò rỉ bộ nhớ.
- **AI Bridge:** Giao tiếp với FastAPI qua `task_id`. Sử dụng StreamSubscription để lắng nghe sự thay đổi status của ảnh từ `PROCESSING` -> `COMPLETED`.
