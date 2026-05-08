---
id: gwueh9
title: Fix FocusScope.of(context) in SpecialistDashboardPage
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-08T04:08:36.998Z'
updatedAt: '2026-05-08T04:13:40.787Z'
timeSpent: 24
spec: specs/standardize-specialist-navigation-and-fix-errors
fulfills:
  - AC-1
---
# Fix FocusScope.of(context) in SpecialistDashboardPage

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sửa file specialist_dashboard_page.dart để không gọi context trong dispose.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Thay thế FocusScope.of(context).unfocus() bằng FocusManager.instance.primaryFocus?.unfocus()
<!-- AC:END -->

