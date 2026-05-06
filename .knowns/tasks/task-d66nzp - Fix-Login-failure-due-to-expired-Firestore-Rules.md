---
id: d66nzp
title: Fix Login failure due to expired Firestore Rules
status: done
priority: high
labels: []
createdAt: '2026-04-30T05:01:45.236Z'
updatedAt: '2026-04-30T05:02:28.692Z'
timeSpent: 31
---
# Fix Login failure due to expired Firestore Rules

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The app currently fails to login with 'Lỗi kết nối dữ liệu người dùng' because Firestore Security Rules expired on 2026-04-30. This task fixes the rules and improves error logging in AuthCubit.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Update firestore.rules to remove hardcoded expiration and enforce auth.
- [x] #2 Add error logging in AuthCubit to capture actual Firestore exceptions.
- [x] #3 Verify login success.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Fixed firestore rules by removing hardcoded expiration and enforcing authentication. Added debug logging to AuthCubit.
<!-- SECTION:NOTES:END -->

