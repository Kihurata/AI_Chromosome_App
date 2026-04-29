---
title: Manager Dashboard
description: Specification for Lab Manager Dashboard functionality.
createdAt: '2026-04-29T13:37:56.676Z'
updatedAt: '2026-04-29T13:59:00.694Z'
tags:
  - spec
  - draft
  - manager
  - dashboard
---

## Overview
Thiết kế và triển khai màn hình Dashboard dành cho vai trò **Lab Manager**. Manager đóng vai trò "nhà điều phối", chịu trách nhiệm phân bổ công việc cho các Specialist, theo dõi tiến độ toàn phòng Lab và phê duyệt các kết quả Karyotype cuối cùng trước khi trả cho bệnh nhân.

## Locked Decisions
- **D1 (Centralized Assignment):** Manager là người duy nhất có quyền phân công phiếu xét nghiệm cho Specialist.
- **D2 (Status-Based Filtering):** Manager Dashboard hiển thị các tab: **Chờ phân công**, **Đang thực hiện**, **Chờ phê duyệt**, **Đã hoàn thành**.
- **D3 (Approval Workflow):** Khi Specialist nộp kết quả, Manager có quyền **Phê duyệt (Approve)** để kết thúc quy trình hoặc **Yêu cầu làm lại (Reject)** nếu kết quả chưa đạt yêu cầu.
- **D4 (Specialist Lookup):** Tích hợp danh sách Specialist đang online/rảnh để tối ưu phân công.

## Requirements

### Functional Requirements
- **FR-1:** Dashboard hiển thị chỉ số tổng quát (Bento Box): Phiếu mới, Phiếu đang xử lý, Phiếu chờ duyệt.
- **FR-2:** Hiển thị danh sách phiếu xét nghiệm chưa có người đảm nhận.
- **FR-3:** Tính năng phân công: Chọn 1 hoặc nhiều phiếu -> Chọn Specialist -> Xác nhận.
- **FR-4:** Theo dõi tiến độ thời gian thực của từng Specialist.
- **FR-5:** Review màn hình Workspace của Specialist (View-only) trước khi phê duyệt.
- **FR-6:** Thực hiện Approve/Reject kết quả kèm theo comment.

### Non-Functional Requirements
- **NFR-1 (Security):** Chỉ người dùng có role `manager` mới truy cập được các API/Actions này.
- **NFR-2 (Real-time):** Danh sách "Chờ phê duyệt" phải cập nhật ngay khi Specialist bấm "Submit for Approval".

## Acceptance Criteria
- [ ] **AC-1:** Manager có thể xem danh sách toàn bộ phiếu xét nghiệm trong hệ thống.
- [ ] **AC-2:** Thao tác phân công cập nhật đúng `specialistId` trên Firestore và làm biến mất phiếu khỏi tab "Chờ phân công".
- [ ] **AC-3:** Khi Reject, trạng thái phiếu quay về `ANALYZING` và Specialist nhận được thông báo.
- [ ] **AC-4:** Khi Approve, trạng thái phiếu chuyển thành `COMPLETED`, hệ thống tự động khóa (lock) dữ liệu NST không cho sửa đổi thêm.

## Scenarios

### Scenario 1: Phân công công việc
**Given** Có 5 phiếu mới vừa được Receptionist đẩy lên.
**When** Manager chọn 5 phiếu này và chọn Specialist "Nguyễn Văn A".
**Then** 5 phiếu này xuất hiện trên Dashboard của Specialist A và biến khỏi danh sách chờ của Manager.

### Scenario 2: Phê duyệt kết quả
**Given** Specialist B vừa hoàn thành phân tích và gửi yêu cầu phê duyệt.
**When** Manager xem qua kết quả và bấm "Approve".
**Then** Trạng thái phiếu chuyển thành "Hoàn thành", bệnh nhân có thể nhận kết quả.

## Technical Notes
- Sử dụng `ManagerDashboardCubit` để quản lý danh sách phiếu.
- `SpecialistLookupService` để lấy danh sách specialist từ collection `users`.
- Tích hợp `AuditLog` cho mọi hành động của Manager.

## Visual Design & Structure (Consolidated)

> [!IMPORTANT]
> Mặc dù các mockup có sự khác biệt về Header/Sidebar, bản triển khai thực tế PHẢI tuân thủ khung Layout chung (`MainShell`). Các thành phần UI bên trong Dashboard sẽ được bóc tách và tích hợp như sau:

### 1. Dashboard Layout Structure
- **Sidebar:** Sử dụng `SideRail` chung của hệ thống (Dark/Expandable) thay vì Sidebar trắng trong mockup để đảm bảo tính nhất quán.
- **Header:** Sử dụng `GlobalHeader` chung với Breadcrumbs và User Profile.
- **Content Area:** Sử dụng tông nền sáng của màn hình "Sidebar Trắng" để làm nổi bật các Card và Table.

### 2. Component Refinement (From Mockups)
- **Specialist Assignment (Screen ID: 1ed008):**
    - Sử dụng Data Table với cột "Trạng thái chuyên viên" và "Số lượng phiếu đang giữ".
    - Action: Nút "Assign" nổi bật, mở Modal chọn nhanh Specialist.
- **Approval Workflow (Screen ID: 7d9106):**
    - **Tối ưu kích thước nút:** Các nút "Approve" (Xanh) và "Reject" (Đỏ) được thiết kế với kích thước lớn, dễ thao tác (UX tối ưu cho việc duyệt nhanh).
    - Vị trí nút: Đặt tại thanh Sticky Bottom Bar hoặc góc trên bên phải để Manager luôn có thể action mà không cần cuộn trang.

### 3. Implementation Mapping
- **ManagerDashboardPage:** Sẽ là một `Scaffold` nằm bên trong `MainShell`.
- **AssignmentFlow:** Sử dụng `showModalBottomSheet` hoặc `showDialog` dựa trên mẫu thiết kế từ screen `1ed008`.
- **ApprovalView:** Một màn hình phụ hoặc Drawer lớn để review chi tiết Workspace của Specialist trước khi bấm Duyệt.
