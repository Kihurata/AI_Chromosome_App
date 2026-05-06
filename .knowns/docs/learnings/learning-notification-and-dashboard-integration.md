---
title: 'Learning: Notification and Dashboard Integration'
description: Learnings from Notification System integration and Specialist Dashboard stabilization.
createdAt: '2026-05-06T16:08:21.435Z'
updatedAt: '2026-05-06T16:08:21.435Z'
tags:
  - learning
  - notification
  - layout
  - flutter
---

## Patterns

### Notification Sound Mapping
- **What:** Reusable logic in `NotificationCubit` to map string-based notification types from Firebase (e.g., `ORDER_COMPLETED`, `ANALYSIS_READY`) to local audio assets.
- **When to use:** In any feature requiring real-time audible alerts based on push notification events.
- **Source:** @task-jjckim

### Robust Dashboard Card Layout
- **What:** Using `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox` + `IntrinsicHeight` for dashboard cards. This ensures `MainAxisAlignment.spaceBetween` works on large screens while allowing scrolling on small/squashed screens.
- **When to use:** For small informative cards (like `StatsCard`) in a GridView or flexible row.
- **Source:** @task-jjckim

## Decisions

### Notification Navigation Tradeoff
- **Chose:** To use `router.go` to Dashboards followed by `cubit.focusOrder` instead of direct `router.push` to specific Workspace/Review pages.
- **Over:** Direct navigation to sub-routes.
- **Tag:** TRADEOFF
- **Outcome:** Maintains the "Dashboard as Home" context where specialists see their full list, but focuses the relevant item. Avoided complex route history management during a major merge.
- **Recommendation:** Use direct push only for deep-link scenarios where the dashboard state isn't required.

### Flutter Color API Migration
- **Chose:** `color.withValues(alpha: 0.1)`
- **Over:** `color.withOpacity(0.1)`
- **Tag:** GOOD_CALL
- **Outcome:** Resolved Flutter 3.10+ deprecation warnings and improved color precision.
- **Recommendation:** Standardize on `withValues` for all new UI components.

## Failures

### Layout Protection Regression
- **What went wrong:** `StatsCard` protection (SingleChildScrollView) was removed during a merge from `main`, leading to overflow crashes on resized browser windows.
- **Root cause:** Lack of a shared "BaseStatCard" widget; protection was applied ad-hoc to an individual component.
- **Time lost:** 30 minutes of debugging and refactoring.
- **Prevention:** Extract shared layout patterns into base widgets in `lib/presentation/widgets/shared/` instead of duplicating logic.
