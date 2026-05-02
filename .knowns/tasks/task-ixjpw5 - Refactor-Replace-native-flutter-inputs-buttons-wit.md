---
id: ixjpw5
title: 'Refactor: Replace native flutter inputs/buttons with Atomic Widgets'
status: in-progress
priority: high
labels: []
createdAt: '2026-05-02T08:43:35.770Z'
updatedAt: '2026-05-02T08:43:55.666Z'
timeSpent: 0
assignee: '@me'
---
# Refactor: Replace native flutter inputs/buttons with Atomic Widgets

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor the entire presentation layer to enforce the 'Atomic Widgets' rule. Replace all direct usages of native Flutter widgets like TextField, TextFormField, ElevatedButton, and OutlinedButton with the project's shared atomic widgets: AppTextField, AppPrimaryButton, and AppSecondaryButton. This ensures visual consistency and adheres to the project's composition-based architecture.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. Audit current atomic widgets: Ensure AppTextField and AppButtons support all needed parameters (icons, validation, padding).
2. Refactor Buttons: Replace ElevatedButton/OutlinedButton with AppPrimaryButton/AppSecondaryButton across all presentation/screens.
3. Refactor Text Fields: Replace TextField/TextFormField with AppTextField, preserving controllers and validation logic.
4. Verification: Run 'dart analyze' and perform visual checks on key screens to ensure no regressions.
<!-- SECTION:PLAN:END -->

