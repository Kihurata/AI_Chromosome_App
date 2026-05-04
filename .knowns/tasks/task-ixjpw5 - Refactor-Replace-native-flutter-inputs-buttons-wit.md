---
id: ixjpw5
title: 'Refactor: Replace native flutter inputs/buttons with Atomic Widgets'
status: in-progress
priority: high
labels: []
createdAt: '2026-05-02T08:43:35.770Z'
updatedAt: '2026-05-03T10:52:05.651Z'
timeSpent: 94101
assignee: '--json'
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
1. Refactor Clinician Dashboard Actions: Consolidate Eye/Stethoscope icons in RecentPatientsTable into a single dynamic button that updates appointment status (scheduled -> inProgress) and navigates to Medical Record.
2. Standardize Buttons: Replace ElevatedButton/OutlinedButton with AppPrimaryButton/AppSecondaryButton across clinician and receptionist modules.
3. Standardize Text Fields: Replace TextField/TextFormField with AppTextField, ensuring controllers and validation are preserved.
4. UI Verification: Perform visual checks on 'Bảng điều khiển bác sĩ' and 'Bệnh án điện tử' to ensure visual consistency and correct workflow behavior.
<!-- SECTION:PLAN:END -->

