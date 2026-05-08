---
id: 6e83jp
title: Add mounted check in ScreeningStep listener
status: done
priority: medium
labels:
  - from-spec
  - go-mode
createdAt: '2026-05-08T04:08:40.662Z'
updatedAt: '2026-05-08T04:13:45.572Z'
timeSpent: 21
spec: specs/standardize-specialist-navigation-and-fix-errors
fulfills:
  - AC-2
---
# Add mounted check in ScreeningStep listener

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sửa file screening_step.dart để bảo vệ các lệnh gọi ScaffoldMessenger bằng if (!context.mounted) return;.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Thêm if (!context.mounted) return; trước ScaffoldMessenger.of(context)
<!-- AC:END -->

