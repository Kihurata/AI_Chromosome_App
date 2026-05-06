---
title: specialist-dashboard-ai-trigger
description: 'Specification for Workspace Upload and AI Trigger Integration'
createdAt: '2026-05-06T08:54:11.361Z'
updatedAt: '2026-05-06T08:54:11.361Z'
tags:
  - spec
  - approved
---

## Overview
Tài liệu này đặc tả luồng công việc của Specialist từ Dashboard vào Workspace, quá trình tải lên bộ ảnh Metaphase trực tiếp trong Workspace Bước 1, và cách kích hoạt phân tích AI sau khi tải ảnh hoàn tất.

## Locked Decisions
- **D1 (Dashboard Navigation):** Nút trên thẻ `SpecialistOrderCard` ở Dashboard được đổi tên thành "Phân Tích". Nút này không có logic phức tạp mà chỉ thực hiện điều hướng trực tiếp vào màn hình `WorkspaceScreen` (Bước 1: Sàng lọc).
- **D2 (In-Workspace Upload):** Hành động upload nhiều ảnh (Multiple Images) được dời vào bên trong Bước 1 của Workspace. Specialist sẽ có một nút "Upload ảnh" để chọn và tải ảnh. Việc upload diễn ra tuần tự, người dùng chờ đến khi toàn bộ file ảnh được tải lên Storage và lưu thành công các record `MetaphaseImage` vào Firestore.
- **D3 (Manual AI Trigger):** Sau khi toàn bộ ảnh được tải lên thành công, một nút "Phân tích AI" sẽ xuất hiện (hoặc được enable) tại Bước 1. Khi Specialist bấm nút này, hệ thống sẽ gọi API `triggerAnalysis` để chạy AI cho toàn bộ ảnh đã upload.
- **D4 (Workspace Processing State):** Sau khi AI được kích hoạt, danh sách các ảnh sẽ hiển thị trạng thái `Processing` (Loading) và tự động cập nhật thành `Completed` (hoặc `Failed`) dựa trên stream từ Firestore.

## Requirements

### Functional Requirements
- **FR-1 (Dashboard Button):** Cập nhật `SpecialistOrderCard` để hiển thị nút "Phân Tích" và chỉ thực hiện `context.goNamed('specialist-analysis', ...)`.
- **FR-2 (Workspace Upload UI):** Tại `ScreeningStep` (Bước 1), thêm nút "Upload ảnh" mở dialog/file picker để chọn nhiều ảnh. Hiển thị rõ tiến trình tải lên (Ví dụ: Đang tải lên 1/5 ảnh...).
- **FR-3 (Trigger Button Logic):** Trong `ScreeningStep`, cung cấp nút "Phân tích AI". Nút này chỉ khả dụng khi đã có ảnh được upload và chưa được phân tích. Khi bấm sẽ gọi `context.read<AiAnalysisCubit>().triggerAnalysis(orderId)`.
- **FR-4 (Processing & Results State):** Các item ảnh trong `ScreeningStep` phải render được trạng thái `Processing` (hiển thị spinner/lottie) và cập nhật giao diện (hiển thị ảnh phân tích) khi nhận được sự thay đổi status thành `Completed` từ Firestore.

### Non-Functional Requirements
- **NFR-1 (UX/Feedback):** Quá trình upload và phân tích AI không được block hoàn toàn tương tác của người dùng với các chức năng điều hướng chung, nhưng cần có loading states rõ ràng.

## Acceptance Criteria
- [ ] **AC-1:** Nút "Phân Tích" trên Dashboard điều hướng chính xác vào Workspace (Bước 1).
- [ ] **AC-2:** Tại Workspace Bước 1, bấm "Upload ảnh" mở hộp thoại chọn file và hệ thống tạo thành công các record `MetaphaseImage` trong Firestore (với status `uploaded`).
- [ ] **AC-3:** Nút "Phân tích AI" ở Bước 1 hiển thị và khả dụng sau khi ảnh được tải lên, bấm vào sẽ gửi lệnh Trigger AI xuống Backend cho Order ID tương ứng.
- [ ] **AC-4:** Khi AI đang xử lý, màn hình hiển thị danh sách các ô ảnh với trạng thái loading.
- [ ] **AC-5:** Khi Backend xử lý xong, ảnh tự động chuyển từ trạng thái Loading sang hiển thị ảnh đã được đánh giá (kèm thông tin AI trả về).

## Scenarios

### Scenario 1: Upload và Trigger AI thành công từ Workspace
**Given** Specialist ở Dashboard, bấm "Phân Tích" để vào Workspace Bước 1.
**When** Bấm "Upload ảnh", chọn 3 ảnh và chờ tải xong.
**Then** Ảnh hiện lên danh sách. Specialist bấm "Phân tích AI". 3 ảnh chuyển sang trạng thái đang xử lý. Khi Backend xong, ảnh tự hiển thị kết quả.

### Scenario 2: Lỗi trong quá trình Trigger
**Given** Specialist đã upload ảnh thành công tại Bước 1.
**When** Bấm "Phân tích AI" nhưng Backend Orchestrator bị lỗi (Network error).
**Then** Hệ thống hiện Snackbar báo lỗi "Không thể gọi AI", ứng dụng vẫn ở lại Bước 1 để Specialist có thể thử lại sau.

## Technical Notes
- Loại bỏ tính năng/BulkUploadDialog khỏi `SampleManagementPage` và tích hợp thẳng vào `ScreeningStep` của `WorkspaceScreen`.
- Đảm bảo `AiAnalysisCubit` và các logic về trạng thái upload được cung cấp trong Provider tree của `WorkspaceScreen`.
