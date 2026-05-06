---
id: dva5dv
title: Separate Sample Detail Route
status: done
priority: medium
labels: []
createdAt: '2026-05-06T07:13:14.279Z'
updatedAt: '2026-05-06T07:17:30.172Z'
timeSpent: 0
assignee: '@me'
---
# Separate Sample Detail Route

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor SampleDetailScreen out of the nested /specialist/samples route so that it can be invoked safely from both the Specialist Dashboard and the Sample Management Page. This resolves lifecycle/routing state collisions.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Update Route Constants**: Add `specialistSampleDetail = '/specialist/sample-detail'` to `AppRoutes`.
2. **Update Router**: In `app_router.dart`, update the `specialist-sample-detail` route to use the new independent path.
3. **Refactor Navigation**:
   - In `specialist_order_card.dart` (Dashboard): Use `context.pushNamed('specialist-sample-detail', ...)` instead of `context.go()`.
   - In `sample_card.dart` (Sample Management): Add a button/action to view sample details using `context.pushNamed()`.
4. **Enhance Detail UI**: Add an `AppBar` with a back button to `SampleDetailScreen` so users can easily return to their previous context (Dashboard or Management) without using the sidebar.

This separation prevents parent screens from being disposed and solves lifecycle collisions, fully resolving the Cubit 'close' errors.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented route separation. Added specialistSampleDetail route in AppRoutes. Updated GoRouter to use it. Switched from context.go to context.pushNamed in SpecialistOrderCard and SampleCard. Added an AppBar to SampleDetailScreen for back navigation.
<!-- SECTION:NOTES:END -->

