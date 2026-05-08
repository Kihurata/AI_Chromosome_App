---
title: Final Report Spec
description: ''
createdAt: '2026-05-08T03:46:50.449Z'
updatedAt: '2026-05-08T03:53:26.765Z'
tags:
  - spec
  - approved
---

## Overview
Đặc tả màn hình tạo báo cáo final trong Workspace của Specialist. Màn hình chia làm 2 phần: Bên trái là trình soạn thảo văn bản (Delta format), bên phải là xem trước (A4 layout).

## Locked Decisions
- D1: Sử dụng định dạng Delta (JSON) cho nội dung soạn thảo.
- D2: Xem trước chỉ cập nhật khi bấm nút.
- D3: Các thông tin khác (ISCN, Patient info) là chỉ đọc.
- D4: Không hiển thị phần thông tin bác sĩ và nút ký số ở góc dưới bên trái.

## Requirements
### Functional Requirements
- FR-1: Hiển thị trình soạn thảo Rich Text ở bên trái (hỗ trợ B, I, List, Link).
- FR-2: Lưu trữ nội dung soạn thảo dưới dạng Delta JSON trong Firestore.
- FR-3: Hiển thị thông tin bệnh nhân và công thức ISCN ở dạng chỉ đọc.
- FR-4: Cập nhật vùng xem trước bên phải khi bấm nút "Cập nhật".
- FR-5: Không hiển thị phần ký số ở góc dưới bên trái.

### Non-Functional Requirements
- NFR-1: Trình soạn thảo mượt mà, hỗ trợ các định dạng cơ bản.
- NFR-2: Xem trước hiển thị đúng định dạng A4.

## Acceptance Criteria
- [ ] AC-1: Chuyên viên có thể gõ văn bản và định dạng ở khung bên trái.
- [ ] AC-2: Khi bấm nút cập nhật, khung bên phải hiển thị đúng nội dung đã gõ.
- [ ] AC-3: Dữ liệu lưu xuống Firestore là chuỗi JSON Delta.
- [ ] AC-4: Thông tin ISCN và bệnh nhân không thể sửa.
