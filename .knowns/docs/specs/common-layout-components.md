---
title: Common Layout Components
description: Specification for common layout components (Header and Side Rail).
createdAt: '2026-04-29T09:08:47.603Z'
updatedAt: '2026-04-29T09:14:43.049Z'
tags:
  - spec
  - approved
  - ui
  - layout
  - common
---

## Overview
Triển khai bộ thành phần giao diện chung (Common Layout Components) bao gồm **Side Rail (Sidebar)** và **Global Header**. Các thành phần này sẽ tạo thành khung (Shell) của ứng dụng, giúp điều hướng đồng nhất giữa các vai trò người dùng (Receptionist, Clinician, Specialist, Manager).

## Locked Decisions
- **D1 (Desktop-First Side Rail):** Sử dụng thanh điều hướng dọc (Side Rail) nằm bên trái màn hình.
- **D2 (Rich Header):** Header chứa Breadcrumbs (phía trái) để chỉ dẫn vị trí, User Profile và Notifications (phía phải).
- **D3 (Collapsible Sidebar):** Side Rail hỗ trợ thu gọn (Collapse) để tối ưu không gian làm việc, đặc biệt là trong màn hình Workspace phân tích NST.

## Requirements

### Functional Requirements
- **FR-1:** Side Rail hiển thị danh sách Menu dựa trên vai trò của User (lấy từ `appNavItems`).
- **FR-2:** Cho phép người dùng thu gọn/mở rộng Side Rail bằng một nút bấm (Toggle).
- **FR-3:** Header hiển thị chính xác đường dẫn hiện tại (Breadcrumbs) dựa trên Route Path.
- **FR-4:** Header hiển thị thông tin User (Tên, Avatar) và tích hợp nút Logout.
- **FR-5:** Header tích hợp Badge thông báo (Notifications).

### Non-Functional Requirements
- **NFR-1 (Consistency):** Sử dụng các Design Tokens từ `lib/core/theme/` (AppColors, AppShadows).
- **NFR-2 (Aesthetics):** Hiệu ứng chuyển cảnh (animation) khi thu gọn Sidebar phải mượt mà.
- **NFR-3 (Clean Architecture):** Tách biệt Widget hiển thị và Logic quản lý trạng thái Sidebar (có thể dùng một `LayoutCubit` đơn giản).

## Acceptance Criteria
- [ ] **AC-1:** Người dùng có thể click vào menu để chuyển trang thành công.
- [ ] **AC-2:** Khi Sidebar thu gọn, chỉ hiển thị Icons; khi mở rộng, hiển thị cả Icons và Labels.
- [ ] **AC-3:** Breadcrumbs tự động thay đổi khi người dùng chuyển từ Dashboard sang trang chi tiết.
- [ ] **AC-4:** Bấm nút Logout trong Header sẽ xóa session và quay về trang Login.

## Scenarios

### Scenario 1: Thu gọn Sidebar để phân tích NST
**Given** Specialist đang ở trang "Phân tích NST".
**When** Specialist bấm nút Toggle trên Sidebar.
**Then** Sidebar thu nhỏ lại chỉ còn Icons, vùng không gian làm việc chính được mở rộng ra.

### Scenario 2: Kiểm tra Breadcrumbs
**Given** Người dùng đang ở trang `/receptionist/patients`.
**When** Người dùng bấm vào một bệnh nhân để xem chi tiết.
**Then** Breadcrumbs trên Header hiển thị: `Tiếp nhận > Danh sách bệnh nhân > [Tên bệnh nhân]`.

## Technical Notes
- **Side Rail:** Xây dựng component `AppSideRail`.
- **Header:** Xây dựng component `AppHeader`.
- **Shell Layout:** Sử dụng `Scaffold` với `body` bao quanh bởi một `Row` chứa `SideRail` và `Expanded content area`.
- **State:** Sử dụng một Provider hoặc Cubit đơn giản để lưu trạng thái `isSidebarCollapsed`.
