---
id: f68xr0
title: Fix Auth Role Reset on F5
status: done
priority: medium
labels: []
createdAt: '2026-05-13T07:08:27.405Z'
updatedAt: '2026-05-13T07:32:16.223Z'
timeSpent: 1416
assignee: '@me'
---
# Fix Auth Role Reset on F5

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Fix the issue where refreshing the page (F5) resets the user's role to Receptionist. Implement Approach A: Use update() instead of set(merge: true) in NotificationCubit to prevent partial document writes on startup/F5.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 NotificationCubit uses update() instead of set(merge: true) for FCM token update.
- [x] #2 Graceful handling if user document does not exist yet (log warning instead of erroring out).
- [x] #3 No regression in existing functionality.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. Modify `d:\AI_Chromosome_App\frontend\lib\logic\bloc
otification
otification_cubit.dart` line 55: change `.set({'fcm_token': token}, SetOptions(merge: true))` to `.update({'fcm_token': token})`.
2. Wrap the `update` call in a try-catch block specifically catching `FirebaseException` to handle `not-found` error if the document doesn't exist on the server yet.
3. Verify the change by running `flutter build web` or checking for lint errors.
4. Update `learnings/learning-auth-role-f5-issue` to reflect that the fix has been applied.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Replaced set(merge: true) with update() in _updateUserToken. Added FirebaseException(not-found) catch to log a warning and skip the update instead of creating a partial document. flutter analyze: no issues. Learning doc updated.
<!-- SECTION:NOTES:END -->

