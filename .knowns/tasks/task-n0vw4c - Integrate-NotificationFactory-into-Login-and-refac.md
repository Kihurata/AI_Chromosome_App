---
id: n0vw4c
title: Integrate NotificationFactory into Login and refactor AuthCubit error handling
status: done
priority: high
labels:
  - presentation
  - from-spec
  - go-mode
createdAt: '2026-05-04T08:27:31.500Z'
updatedAt: '2026-05-04T08:33:01.179Z'
timeSpent: 0
spec: specs/global-notification-system
---
# Integrate NotificationFactory into Login and refactor AuthCubit error handling

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor login_page.dart BlocListener to use NotificationFactory. Update AuthCubit to detect network errors (SocketException) vs auth errors. Integrate ConnectivityBanner into main.dart app shell.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Refactor AuthCubit: add network error detection (SocketException, etc.)
2. Refactor login_page.dart: replace raw SnackBar with NotificationFactory calls
3. Integrate ConnectivityCubit + ConnectivityBanner into main.dart
4. Run flutter analyze on all changed files
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Refactored AuthCubit with AuthErrorWithType state + NotificationType enum. Added network error detection (SocketException, timeout, host lookup). Refactored login_page.dart to use NotificationFactory. Integrated ConnectivityCubit + ConnectivityBanner into main.dart. Updated auth_provider.dart to handle AuthErrorWithType. All 8 files pass flutter analyze.
<!-- SECTION:NOTES:END -->

