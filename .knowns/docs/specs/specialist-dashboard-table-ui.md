---
title: "Specialist Dashboard - Table Column Headers UI"
description: "Tinh chỉnh UI danh sách phiếu xét nghiệm trên trang Tổng Quan Specialist thành dạng bảng có header row khớp với Stitch design"
tags:
  - spec
  - approved
---

## Overview

Chuyển danh sách phiếu xét nghiệm trên trang Tổng Quan Specialist từ dạng card (mỗi item 1 card riêng) sang dạng **bảng có header row** với 4 cột: Bệnh nhân, Xét nghiệm, Ngày yêu cầu, và Hành động. Tất cả nội dung trong bảng được căn lề giữa theo chiều ngang trong từng cột, khớp với design screen "Bảng điều khiển Chuyên viên" trên Stitch.

## Locked Decisions

- **D1 (Table vs Card):** Chuyển hoàn toàn sang dạng bảng (`Table`/`DataTable` hoặc layout thủ công với `Row`), giữ nguyên header row cố định ở đầu.
- **D2 (Column headers):** Sử dụng đúng 4 tiêu đề từ Stitch: **Bệnh nhân** · **Xét nghiệm** · **Ngày yêu cầu** · **Hành động**.
- **D3 (Alignment):** Toàn bộ header và cell content được căn giữa (`TextAlign.center` / `CrossAxisAlignment.center`).

## Requirements

### Functional Requirements
- **FR-1:** Header row hiển thị cố định ở đầu danh sách với 4 tiêu đề: **Bệnh nhân**, **Xét nghiệm**, **Ngày yêu cầu**, **Hành động**.
- **FR-2:** Mỗi row dữ liệu hiển thị:
  - *Bệnh nhân*: Tên bệnh nhân + mã phiếu (sub-label nhỏ hơn)
  - *Xét nghiệm*: Loại xét nghiệm (hiện đang dùng `order.patientCode` làm placeholder — giữ nguyên mapping hiện tại)
  - *Ngày yêu cầu*: Ngày tạo phiếu định dạng `dd/MM/yyyy`
  - *Hành động*: Badge trạng thái + nút action ("Bắt đầu phân tích" hoặc "Tiếp tục")
- **FR-3:** Toàn bộ nội dung header và cell được căn giữa.
- **FR-4:** Hành vi click row (navigate tới Sample Detail) và các nút action phải được giữ nguyên — không bị mất.
- **FR-5:** Trạng thái empty (không có phiếu) phải vẫn hiển thị đúng.

### Non-Functional Requirements
- **NFR-1:** Không thay đổi Domain/Data/Logic layers — chỉ sửa UI widget files.

## Acceptance Criteria

- [ ] **AC-1:** Trang Tổng Quan Specialist hiển thị header row với đúng 4 cột: Bệnh nhân, Xét nghiệm, Ngày yêu cầu, Hành động.
- [ ] **AC-2:** Nội dung mỗi cột được căn giữa.
- [ ] **AC-3:** Nút "Bắt đầu phân tích" và "Tiếp tục" hoạt động bình thường.
- [ ] **AC-4:** Click vào một row vẫn điều hướng sang trang Chi tiết Mẫu bệnh phẩm.

## Scenarios

### Scenario 1: Hiển thị bảng có dữ liệu
**Given** Specialist đăng nhập và có phiếu xét nghiệm được giao
**When** Màn hình Tổng Quan tải xong
**Then** Hiển thị bảng với header "Bệnh nhân · Xét nghiệm · Ngày yêu cầu · Hành động" và các row dữ liệu tương ứng, tất cả căn giữa.

### Scenario 2: Empty state
**Given** Specialist chưa được giao phiếu nào
**When** Màn hình Tổng Quan tải xong
**Then** Hiển thị UI empty state như cũ (icon inbox + text thông báo).

## Technical Notes

- Sửa tập trung tại: `specialist_order_list.dart` (thêm header row) và `specialist_order_card.dart` (chuyển layout thành table row với căn giữa).
- Cân nhắc dùng `Table` widget của Flutter với `columnWidths` fixed-flex thay cho `DataTable` để dễ tùy biến style hơn.
