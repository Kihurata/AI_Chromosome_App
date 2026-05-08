---
title: Hiển thị Karyotype trên Phiếu kết quả
description: Specification for Karyotype display on report
folder: specs
tags: [spec, approved]
---

## Overview

Tự động vẽ và hiển thị bộ nhiễm sắc thể đã sắp xếp (Karyotype) trên phiếu kết quả xét nghiệm di truyền (Phần Preview) bằng các Widget Flutter dựa trên dữ liệu từ các bước trước.

## Locked Decisions

Decisions extracted during exploring phase:
- **D1**: Hình ảnh Karyotype sẽ được tự động sinh ra từ dữ liệu sắp xếp ở các bước trước.
- **D2**: Frontend tự vẽ lại bố cục Karyotype bằng Widget Flutter trên phiếu kết quả (Không tạo file ảnh mới).
- **D3**: Vị trí hiển thị của Karyotype là ở giữa, dưới phần "CÔNG THỨC ISCN" và trên phần "Mô tả chi tiết".
- **D4**: Frontend sẽ chia hàng cố định theo chuẩn y tế (Hàng 1: 1-5, Hàng 2: 6-12, Hàng 3: 13-18, Hàng 4: 19-22, X, Y).

## Requirements

### Functional Requirements
- **FR-1**: Hệ thống phải lấy dữ liệu danh sách nhiễm sắc thể đã được phân loại và sắp xếp từ bước trước (hoặc từ TestOrder).
- **FR-2**: Frontend phải tự động sắp xếp các nhiễm sắc thể này vào một lưới có cấu trúc 4 hàng theo đúng chuẩn y tế (như D4).
- **FR-3**: Hiển thị lưới Karyotype này trên phần Preview của Báo cáo Final (Report Step).
- **FR-4**: Cập nhật hiển thị Karyotype khi người dùng nhấn nút "Cập nhật xem trước".

### Non-Functional Requirements
- **NFR-1**: Hiệu năng: Việc vẽ lại lưới không được làm đơ giao diện.
- **NFR-2**: Thẩm mỹ: Các ảnh NST phải được căn chỉnh cân đối, có nhãn số thứ tự cặp NST bên dưới mỗi cặp.

## Acceptance Criteria

- [ ] **AC-1**: Xuất hiện vùng hiển thị Karyotype trên tờ phiếu kết quả (Preview) nằm đúng vị trí quy định ở D3.
- [ ] **AC-2**: Các nhiễm sắc thể được xếp thành 4 hàng:
    - Hàng 1: Cặp 1 - 5
    - Hàng 2: Cặp 6 - 12
    - Hàng 3: Cặp 13 - 18
    - Hàng 4: Cặp 19 - 22, X, Y
- [ ] **AC-3**: Mỗi vị trí cặp NST hiển thị hình ảnh của NST đó (hoặc để trống nếu chưa có dữ liệu).
- [ ] **AC-4**: Giao diện hiển thị rõ ràng, chuyên nghiệp tương tự như ảnh mẫu người dùng cung cấp.

## Scenarios

### Scenario 1: Hiển thị đầy đủ
**Given** Ca xét nghiệm đã hoàn thành bước phân loại và sắp xếp đầy đủ 46 nhiễm sắc thể.
**When** Chuyên viên vào bước tạo báo cáo và nhấn "Cập nhật xem trước".
**Then** Phiếu kết quả hiển thị đầy đủ hình ảnh các nhiễm sắc thể được xếp đúng vị trí 4 hàng.

### Scenario 2: Thiếu dữ liệu
**Given** Ca xét nghiệm chưa hoàn thành phân loại một số nhiễm sắc thể.
**When** Chuyên viên vào bước tạo báo cáo và nhấn "Cập nhật xem trước".
**Then** Các vị trí thiếu dữ liệu sẽ hiển thị khung trống (Placeholder) hoặc số thứ tự nhưng không có ảnh.
