---
id: nc0jko
title: Create NotificationType Enum and NotificationFactory class
status: done
priority: high
labels:
  - core
  - from-spec
  - go-mode
createdAt: '2026-05-04T08:27:17.931Z'
updatedAt: '2026-05-04T08:29:21.454Z'
timeSpent: 0
spec: specs/global-notification-system
---
# Create NotificationType Enum and NotificationFactory class

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create the core NotificationType enum (SUCCESS, INFO, WARNING, ERROR, ERROR_RETRY, VALIDATION_ERROR) and NotificationFactory class with static methods for rendering Snackbars and AlertDialogs based on type. Place in core/services/.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create NotificationType enum in core/services/notification_factory.dart
2. Create NotificationFactory class with static methods: showSuccess, showInfo, showWarning, showError, showErrorRetry, showValidationError
3. Snackbar variants: floating behavior, icon + message, auto-dismiss, slide animation
4. Dialog variants: for ERROR_RETRY type with retry callback
5. Use AppColors from design system for consistent theming
6. Run dart analyze
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created NotificationType enum (6 types) and NotificationFactory class with static methods. All Snackbar variants use AppColors design system, floating behavior, icons. AlertDialog for errorRetry with retry callback. dart analyze: No issues found.
<!-- SECTION:NOTES:END -->

