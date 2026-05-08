---
id: drec59
title: Xây dựng giao diện Editor và Preview cho Báo cáo Final
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-08T04:56:09.566Z'
updatedAt: '2026-05-08T05:00:35.096Z'
timeSpent: 242
spec: specs/final-report-spec
fulfills:
  - AC-1
  - AC-2
  - AC-4
---
# Xây dựng giao diện Editor và Preview cho Báo cáo Final

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng layout chia đôi, bên trái là Rich Text Editor (Quill) và bên phải là Preview A4. Hiển thị thông tin ISCN và bệnh nhân dạng chỉ đọc.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Tạo giao diện chia đôi (split screen).
- [ ] #2 Tích hợp Flutter Quill làm editor bên trái.
- [ ] #3 Hiển thị thông tin bệnh nhân và ISCN dạng chỉ đọc.
- [ ] #4 Nút cập nhật kích hoạt render lại bên phải.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Tìm file màn hình Workspace và xác định vị trí bước tạo báo cáo.
2. Thiết kế layout chia đôi (Split Screen).
3. Tích hợp thư viện flutter_quill làm editor.
4. Hiển thị thông tin bệnh nhân và ISCN dạng chỉ đọc.
5. Xử lý sự kiện bấm nút Cập nhật để render preview.
<!-- SECTION:PLAN:END -->

