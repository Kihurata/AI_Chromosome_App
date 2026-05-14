---
id: sba8z9
title: 'Flutter dispose(): KHÔNG dùng FocusScope.of(context) — context đã deactivated'
layer: project
category: failure
tags:
  - debug
  - flutter
  - lifecycle
  - dispose
createdAt: '2026-05-14T11:40:55.803Z'
updatedAt: '2026-05-14T11:40:55.803Z'
---

Root cause: Gọi `FocusScope.of(context)` trong `dispose()` gây lỗi "Looking up a deactivated widget's ancestor is unsafe" vì context đã bị Flutter unmount tại thời điểm dispose chạy.

Fix: Xóa hoàn toàn dòng `FocusScope.of(context).unfocus()` khỏi dispose(). Flutter tự động unfocus khi navigate đi, không cần gọi tay.

Các file bị ảnh hưởng trong project (pattern lặp lại):
- receptionist_dashboard_body.dart
- patient_list_page.dart  
- patient_registration_page.dart
- lab_manager_dashboard_page.dart
- doctor_dashboard_page.dart
- sample_detail_screen.dart

Quy tắc: Không bao giờ dùng `context` bên trong `dispose()` — kể cả FocusScope, Navigator, ScaffoldMessenger, v.v.
