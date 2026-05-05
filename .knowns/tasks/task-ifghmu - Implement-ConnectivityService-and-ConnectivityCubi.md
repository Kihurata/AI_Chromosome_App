---
id: ifghmu
title: Implement ConnectivityService and ConnectivityCubit
status: done
priority: high
labels:
  - core
  - from-spec
  - go-mode
createdAt: '2026-05-04T08:27:25.191Z'
updatedAt: '2026-05-04T08:30:48.072Z'
timeSpent: 0
spec: specs/global-notification-system
---
# Implement ConnectivityService and ConnectivityCubit

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create ConnectivityService using connectivity_plus package to monitor network state in real-time, and ConnectivityCubit to expose the state to UI via BLoC pattern. Include ConnectivityBanner widget.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create ConnectivityService in core/services/connectivity_service.dart
2. Create ConnectivityCubit + ConnectivityState in logic/bloc/connectivity/
3. Create ConnectivityBanner widget in presentation/widgets/
4. Run flutter analyze
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created ConnectivityService (connectivity_plus wrapper), ConnectivityCubit (stream listener with isClosed guard), and ConnectivityBanner widget (animated slide/fade). All pass dart analyze.
<!-- SECTION:NOTES:END -->

