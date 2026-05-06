---
id: jjckim
title: Fix Notification and Sound Issues
status: done
priority: high
labels: []
createdAt: '2026-05-06T07:34:16.347Z'
updatedAt: '2026-05-06T07:35:01.726Z'
timeSpent: 0
spec: specs/notification-system-expansion
---
# Fix Notification and Sound Issues

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Debug and fix notification/sound issues for role-based actions.
1. Move BlocListener inside MaterialApp to fix context issues.
2. Align status strings between Frontend (IN_PROGRESS) and Backend (ANALYZING).
3. Handle shared FCM token behavior in documentation/notes.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Notification snackbars appear correctly on the screen.
- [x] #2 Backend correctly triggers analysis and notifications for IN_PROGRESS status.
- [x] #3 Specialist receives assignment notifications (when using real IDs).
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
🐛 Debug: 
1. Tín hiệu chuông (sound) mà Clinician nghe thấy thực chất là do trình duyệt chia sẻ FCM token giữa các tab. Khi thông báo gửi tới Manager, cả tab Clinician cũng nhận được.
2. Thông báo không hiện (UI) là do BlocListener nằm ngoài MaterialApp, dẫn đến context không có ScaffoldMessenger.
3. Việc Manager chỉ định Specialist không có chuông là do trước đó dùng Mock ID (spec_01) không có trong DB nên Backend không tìm thấy token. Ngoài ra, Backend đang bỏ qua trạng thái IN_PROGRESS.
<!-- SECTION:NOTES:END -->

