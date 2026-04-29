---
title: Specialist Dashboard
description: Specification for Lab Specialist Dashboard functionality.
createdAt: '2026-04-29T09:01:49.805Z'
updatedAt: '2026-04-29T09:14:43.404Z'
tags:
  - spec
  - approved
  - specialist
  - dashboard
---

## Overview
Thiết kế và triển khai màn hình Dashboard dành cho vai trò **Lab Specialist**. Đây là nơi chuyên viên quản lý danh sách các phiếu xét nghiệm được phân công, theo dõi tiến độ công việc qua các chỉ số thống kê (Bento Box) và thực hiện các thao tác tìm kiếm, lọc và bắt đầu phân tích.

## Locked Decisions
- **D1 (Real-time Sync):** Dashboard lắng nghe Stream từ Firestore để cập nhật danh sách phiếu và trạng thái AI ngay lập tức.
- **D2 (Logic in Cubit):** Các chỉ số thống kê (Chờ xử lý, Đang phân tích, Chờ duyệt, Hoàn thành) được tính toán trong Cubit và đẩy ra UI qua object `SpecialistStats`.
- **D3 (Search & Filter):** Hỗ trợ tìm kiếm theo tên/mã bệnh nhân và lọc theo trạng thái phiếu.
- **D4 (Manual Transition):** Trạng thái phiếu chuyển từ "Chờ xử lý" sang "Đang phân tích" thông qua thao tác bấm nút "Bắt đầu" thủ công của Specialist.

## Requirements

### Functional Requirements
- **FR-1:** Hiển thị Bento Box với 4 chỉ số thống kê thời gian thực.
- **FR-2:** Hiển thị danh sách các phiếu xét nghiệm (TestOrder) được phân công cho Specialist hiện tại.
- **FR-3:** Tìm kiếm phiếu theo `patientName` hoặc `patientCode` (Local search trên danh sách đã fetch).
- **FR-4:** Lọc danh sách theo `status`.
- **FR-5:** Cập nhật trạng thái phiếu sang `ANALYZING` khi người dùng xác nhận bắt đầu.
- **FR-6:** Điều hướng người dùng tới màn hình **Workspace** khi chọn một phiếu.

### Non-Functional Requirements
- **NFR-1 (UX):** Các chỉ số thống kê phải cập nhật mượt mà khi có thay đổi từ Firestore (Backend xử lý xong AI hoặc Manager phân công mới).
- **NFR-2 (Clean Architecture):** Tuân thủ tuyệt đối việc tách biệt Logic (Cubit) và Presentation (UI).

## Acceptance Criteria
- [ ] **AC-1:** Dashboard hiển thị đúng số lượng phiếu theo từng trạng thái trong Bento Box.
- [ ] **AC-2:** Thanh tìm kiếm lọc đúng kết quả hiển thị trên danh sách.
- [ ] **AC-3:** Bấm nút "Bắt đầu" trên một phiếu "Chờ xử lý" sẽ cập nhật status lên Firestore thành `ANALYZING`.
- [ ] **AC-4:** Khi một phiếu mới được phân công từ Manager, nó phải xuất hiện ngay lập tức trên Dashboard của Specialist mà không cần tải lại trang.

## Scenarios

### Scenario 1: Specialist bắt đầu làm việc
**Given** Specialist đang ở Dashboard và thấy một phiếu mới ở trạng thái "Chờ xử lý".
**When** Specialist bấm vào phiếu đó và chọn "Bắt đầu phân tích".
**Then** Trạng thái phiếu trên Firestore chuyển thành `ANALYZING` và Specialist được điều hướng vào màn hình Workspace.

### Scenario 2: Tìm kiếm bệnh nhân
**Given** Danh sách có 10 phiếu với các tên bệnh nhân khác nhau.
**When** Specialist gõ "Nguyễn Văn A" vào thanh tìm kiếm.
**Then** Danh sách chỉ hiển thị các phiếu của bệnh nhân có tên khớp với từ khóa.

## Technical Notes
- Sử dụng `Riverpod` để stream danh sách phiếu từ `WorkspaceRepository`.
- `SpecialistDashboardCubit` sẽ quản lý cả Stream subscription và logic filtering/search cục bộ để tối ưu performance.
- Dữ liệu Specialist hiện tại lấy từ `AuthService`.
