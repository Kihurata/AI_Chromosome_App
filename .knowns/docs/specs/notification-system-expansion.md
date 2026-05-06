---
title: Notification System Expansion
description: ''
createdAt: '2026-05-05T07:51:01.555Z'
updatedAt: '2026-05-05T08:11:46.785Z'
tags: []
---

# Specification: Notification System (UI-Only / Ephemeral)

## Overview
This document specifies a simplified, non-persistent notification system. Notifications are delivered via Push FCM and displayed in-app as temporary UI elements (Snackbars/Dialogs) using the existing `NotificationFactory`.

## 1. Notification Matrix (Trigger Only)
Events remain the same, but the delivery is purely ephemeral.

| Event ID | recipient Role | Channel | Priority |
| :--- | :--- | :--- | :--- |
| `ORDER_PENDING` | **Lab Manager** | Push/UI | Medium |
| `ORDER_ASSIGNED` | **Lab Specialist** | Push/UI | High |
| `ANALYSIS_READY` | **Lab Manager** | Push/UI | High |
| `ORDER_COMPLETED` | **Clinician** | Push/UI | High |
| `ORDER_REJECTED` | **Lab Specialist** | Push/UI | High |

## 2. Data Strategy
- **Firestore**: No `notifications` collection will be created.
- **Audit Logs**: Status changes are still logged for system traceability, but NOT as user notifications.

## 3. Backend Implementation (Python)
- `NotificationService.py`: 
  - REMOVE `_save_notification`.
  - `send_to_user` and `send_to_role` will only invoke Firebase Messaging (FCM).

## 4. Frontend Implementation (Flutter)
- **FCM Listener**: Implement a foreground message handler in `main.dart` or a `NotificationCubit`.
- **UI Feedback**: When a message is received, call `NotificationFactory.show()` to display a Snackbar or Dialog based on the `type` payload.
- **Notification Bell**: (Optional) Could show a session-based badge, but will be cleared upon app restart.

## 5. Acceptance Criteria
- [ ] Backend sends FCM push when status changes.
- [ ] Frontend catches the foreground message.
- [ ] `NotificationFactory` renders the appropriate popup while the app is active.
