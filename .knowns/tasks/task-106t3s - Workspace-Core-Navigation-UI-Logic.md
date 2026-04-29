---
id: 106t3s
title: 'Workspace Core & Navigation (UI/Logic)'
status: done
priority: high
labels:
  - ui
  - logic
  - workspace
createdAt: '2026-04-29T15:03:06.680Z'
updatedAt: '2026-04-29T18:04:52.048Z'
timeSpent: 60
spec: specs/specialist-workspace
fulfills:
  - FR-6
  - AC-1
---
# Workspace Core & Navigation (UI/Logic)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai WorkspaceCubit để quản lý trạng thái Stepper (Bước 1 -> 5). Cấu hình GoRouter với AppRoutes.specialistAnalysis và các nested routes. Xây dựng WorkspaceScreen kế thừa MainShell.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Update WorkspaceState and WorkspaceCubit to track `currentStep` (1-5) and handle step navigation logic (prevent skipping ahead).
2. Create `WorkspaceScreen` (lib/presentation/screens/workspace/workspace_screen.dart) with a 5-step Stepper layout and a placeholder for each step.
3. Update `AppRouter` to add the `specialistAnalysis` route mapped to `WorkspaceScreen`.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented WorkspaceCubit with currentStep and maxReachedStep. Created WorkspaceScreen with 5-step Stepper layout. Configured AppRouter for specialistAnalysis route.
<!-- SECTION:NOTES:END -->

