---
id: ylqj8k
title: 'Data Binding & Logic Integration for Role Screens'
status: done
priority: high
labels: []
createdAt: '2026-05-03T04:26:52.716Z'
updatedAt: '2026-05-03T07:35:35.942Z'
timeSpent: 11309
assignee: '@me'
---
# Data Binding & Logic Integration for Role Screens

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ensure all table column labels and displayed information across role-based screens accurately reflect the properties of the domain models. Wire up Cubit/Riverpod logic to any screens currently displaying mock data or lacking data-fetching logic.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **SharedMedicalRecordPage**: Inject PatientCubit and call etchPatientById(widget.id) to load real data. Replace hardcoded 'Johnathan Doe' with state.patient.fullName.
2. **PatientInfoTab**: Refactor to accept Patient entity. Map ullName, phone, dob, gender, patientCode, and ddress to the UI fields. Remove non-existent fields like 'VIP status'.
3. **TestResultsTab**: Integrate ClinicianOrderCubit. Use BlocBuilder to listen to TestOrdersLoaded. Filter orders by patientId and display real test history in the AppDataTable.
4. **HistoryTab**: Integrate ExaminationCubit. Use BlocBuilder to display real clinical examination records instead of the current 3 mock timeline items.
5. **Validation**: Run lutter analyze and verify that all screens correctly reflect the domain model attributes defined in lib/domain/entities.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented real data binding for patient detail role screens. Integrated PatientCubit, ClinicianOrderCubit, and ExaminationCubit to replace mock data in SharedMedicalRecordPage and its tabs (Info, History, Test Results). Verified with flutter analyze.
<!-- SECTION:NOTES:END -->

