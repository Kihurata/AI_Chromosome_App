---
id: fsnb6s
title: Optimize Search and Filter Bar UI
status: done
priority: medium
labels: []
createdAt: '2026-05-07T06:58:41.539Z'
updatedAt: '2026-05-07T07:00:55.178Z'
timeSpent: 128
assignee: '@me'
---
# Optimize Search and Filter Bar UI

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor AppDashboardFilterBar to improve visual alignment, color visibility, and responsive width. 
1. Match Filter button height with Search input field.
2. Shrink Filter button width (adjust flex ratio).
3. Change Filter button color to clinical blue.
4. Ensure consistent styling (border radius, padding).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Filter button height matches Search input field exactly.
- [x] #2 Filter button width is reduced (flex ratio 8.5:1.5 or 9:1).
- [x] #3 Filter button uses AppColors.primaryBlue and follows design system.
- [x] #4 Active filter state is visually indicated (optional but recommended).
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Modify `AppDashboardFilterBar` in `lib/presentation/widgets/shared/form/dashboard_filter_bar.dart`:
   - Wrap Row content in `IntrinsicHeight` to allow button to match input height.
   - Adjust `flex` ratio of Search Input vs Filter Button (e.g., 85/15 or 90/10).
   - Pass a custom `backgroundColor` and `textColor` to `AppSecondaryButton` to achieve the blue look, or switch to `AppPrimaryButton` with adjusted padding.
2. Update `AppSecondaryButton` style in `lib/presentation/widgets/shared/form/app_buttons.dart` if necessary to support flexible heights/colors.
3. Verify visual alignment and responsiveness on various screen widths.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented UI optimizations for search and filter bar. Match heights using IntrinsicHeight, reduced button width, applied primary blue color, and added active filter badge.
<!-- SECTION:NOTES:END -->

