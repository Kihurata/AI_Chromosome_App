---
id: dup1xy
title: 'Frontend: Notification UI & Real-time Stream'
status: done
priority: medium
labels: []
createdAt: '2026-05-05T07:54:21.713Z'
updatedAt: '2026-05-05T13:23:19.473Z'
timeSpent: 1121
assignee: '@me'
spec: specs/notification-system-expansion
fulfills:
  - Section 4.1
---
# Frontend: Notification UI & Real-time Stream

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng phần giao diện chuông thông báo và Cubit để lắng nghe thông báo thời gian thực từ Firestore.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Triển khai Firebase Messaging listener trong Foreground.
- [x] #2 Khi nhận tin nhắn, gọi NotificationFactory.show() để hiển thị Snackbar hoặc Dialog.
- [x] #3 Mapping dữ liệu từ 'data' payload của FCM sang NotificationType tương ứng.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Frontend: Implement Firebase Messaging foreground listener (using FirebaseMessaging.onMessage).
2. Logic: Create a simple NotificationCubit or use the existing listener to catch RemoteMessage.
3. UI: Invoke NotificationFactory.show() when a message arrives. Map 'type' from FCM data payload to NotificationType (success, error, etc.).
4. AppHeader: Keep the static bell or implement a session-based counter if needed.
5. Testing: Trigger a status change from the backend and verify the Snackbar appears in the Flutter app.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Đã triển khai hệ thống thông báo UI-only. Tận dụng NotificationFactory để hiển thị Snackbar/Dialog khi nhận tín hiệu FCM. Mapping thành công các loại sự kiện từ Backend sang UI types.
Đã hoàn tất tích hợp Firebase Messaging Foreground Listener và kết nối với NotificationFactory. Hệ thống thông báo UI-only hiện đã hoạt động đồng bộ với Backend.
<!-- SECTION:NOTES:END -->

