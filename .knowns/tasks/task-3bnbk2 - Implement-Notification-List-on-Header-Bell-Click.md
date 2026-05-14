---
id: 3bnbk2
title: Implement Notification List on Header Bell Click
status: done
priority: medium
labels:
  - ui
  - logic
  - notification
createdAt: '2026-05-13T07:56:26.366Z'
updatedAt: '2026-05-13T14:54:40.735Z'
timeSpent: 25086
assignee: '@me'
---
# Implement Notification List on Header Bell Click

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Thực hiện chức năng khi click vào button Thông báo trên thanh header sẽ hiển thị một list các thông báo vừa được gửi tới. Cần cập nhật NotificationCubit để lưu trữ danh sách thông báo trong session.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Update NotificationState to include a notifications list and unread count
- [x] #2 Update NotificationCubit._handleMessage to append to the list without resetting it
- [x] #3 Update AppHeader._buildNotificationBell to use BlocBuilder and show badge count
- [x] #4 Show notification dropdown/popup with title and body when bell is clicked
- [x] #5 Verify badge count updates when new notification arrives
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Update NotificationCubit State**: Add a list to store received notifications in the current session.
2. **Update NotificationCubit Logic**: Append new messages to the list in `_handleMessage`.
3. **Refactor AppHeader's `_buildNotificationBell()`**:
    - Listen to `NotificationCubit` for the notification list.
    - Display the actual count of notifications on the badge.
    - Show a list of notifications (title, body) in a dropdown or popup when clicked.
4. **Verification**: Simulate receiving a notification and verify the list displays correctly.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented notification list feature:
- notification_state.dart: Added abstract NotificationState base, NotificationItem model, NotificationListState (accumulates session list + unreadCount), kept NotificationReceived as one-shot trigger
- notification_cubit.dart: _sessionNotifications list accumulates messages, _handleMessage appends then emits NotificationReceived momentarily before restoring NotificationListState. Added markAllRead() method.
- app_header.dart: _buildNotificationBell refactored to PopupMenuButton showing _NotificationDropdown panel. Badge shows live unread count, cleared when panel opens. _NotificationDropdown has header row, empty state, and scrollable list. _NotificationTile shows colored dot by type, title, body (2 lines), and relative time.
dart analyze: No issues found.
<!-- SECTION:NOTES:END -->

