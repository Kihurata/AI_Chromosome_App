---
id: 2tou5t
title: Refactor Receptionist UI to Clean Architecture
status: done
priority: high
labels:
  - ui
  - refactor
  - receptionist
  - clean-architecture
createdAt: '2026-04-27T17:15:12.664Z'
updatedAt: '2026-04-28T07:51:34.107Z'
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
- [x] #1 Refactor PatientRegistrationPage to use PatientCubit
- [x] #2 Remove ClinicalRepository dependency from 7 files
- [x] #3 Replace direct Firestore calls with Cubit patterns
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Completed migration of Receptionist UI to Clean Architecture. All 7 presentation files (screens and widgets) are now consuming PatientCubit and AppointmentCubit instead of direct repositories or Firestore.
<!-- SECTION:NOTES:END -->

