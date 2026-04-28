---
id: 2tou5t
title: Refactor Receptionist UI to Clean Architecture
status: in-progress
priority: high
labels:
  - ui
  - refactor
  - receptionist
  - clean-architecture
createdAt: '2026-04-27T17:15:12.664Z'
updatedAt: '2026-04-27T17:15:12.664Z'
timeSpent: 0
assignee: '@me'
---
# Refactor Receptionist UI to Clean Architecture

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Remove all ClinicalRepository and direct cloud_firestore dependencies from the Receptionist Presentation layer. Replace with BlocBuilder/BlocListener patterns consuming AppointmentCubit. Affects 7 files across screens and widgets.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

