---
id: 4gd94n
title: 'Backend: Expand Notification Logic'
status: done
priority: high
labels: []
createdAt: '2026-05-05T07:54:17.598Z'
updatedAt: '2026-05-05T13:20:18.862Z'
timeSpent: 169
assignee: '@me'
spec: specs/notification-system-expansion
fulfills:
  - Section 3.1
  - Section 3.2
---
# Backend: Expand Notification Logic

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mở rộng FirestoreListener.py để bắt các trạng thái mới và cập nhật NotificationService.py để gửi Push FCM + lưu vào Firestore notifications.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Implement notify_new_order_pending, notify_analysis_ready, notify_result_approved, notify_result_rejected in NotificationService.py.
- [x] #2 Cập nhật FirestoreListener.py để trigger các hàm thông báo khi trạng thái TestOrder thay đổi.
- [x] #3 Đảm bảo mỗi thông báo đều được lưu vào collection notifications trong Firestore.
- [x] #4 Ghi log thay đổi vào audit_logs cho mỗi thông báo gửi đi.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Modify backend/app/services/notification_service.py: Implement specific notification methods and update send_to_user to save docs to Firestore notifications collection.
2. Modify backend/app/services/firestore_listener.py: Expand on_snapshot logic to detect TestOrder status transitions (WAITING_APPROVAL, COMPLETED, REJECTED).
3. Update AuditService logic to ensure notification events are logged.
4. Create backend/scripts/test_notification_flow.py to verify all triggers and persistence.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã triển khai NotificationService mở rộng và FirestoreListener trigger. Hệ thống hỗ trợ cả Push FCM và In-App notification persistence.
Thay đổi yêu cầu: Chuyển sang hệ thống thông báo tạm thời (UI-only). Cần loại bỏ logic lưu Firestore.
Đã điều chỉnh logic sang chỉ gửi Push FCM (không lưu Firestore) theo yêu cầu mới. AC lưu Firestore đã được bỏ qua/xóa bỏ trong thiết kế mới.
Đã hoàn thành mở rộng NotificationService và FirestoreListener cho Backend. Hệ thống đã sẵn sàng bắn Push FCM cho các trạng thái: PENDING, WAITING_APPROVAL, COMPLETED, REJECTED mà không cần lưu DB.
<!-- SECTION:NOTES:END -->

