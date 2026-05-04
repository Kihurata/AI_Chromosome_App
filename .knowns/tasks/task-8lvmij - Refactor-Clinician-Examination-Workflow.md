---
id: 8lvmij
title: Refactor Clinician Examination Workflow
status: in-progress
priority: high
labels: []
createdAt: '2026-05-04T11:59:32.487Z'
updatedAt: '2026-05-04T11:59:41.092Z'
timeSpent: 0
assignee: '@me'
---
# Refactor Clinician Examination Workflow

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor clinician forms, fix saving logic, and improve data visibility.
1. Remove administrative sections from ExaminationForm and BloodTestPrescription.
2. Synchronize date/time pickers.
3. Fix 'Save' performance and redirect logic.
4. Resolve PatientInfoTab loading issues.
5. Ensure data reflects in Medical History and Manager Dashboard.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Remove administrative sections from ExaminationForm and BloodTestPrescriptionScreen.
- [ ] #2 Implement standard date/time pickers in both forms.
- [ ] #3 Fix Firestore empty path segment error by ensuring IDs are loaded.
- [ ] #4 Improve save performance (investigate serial calls).
- [ ] #5 Fix PatientInfoTab data loading logic.
- [ ] #6 Verify data visibility in HistoryTab and Manager Dashboard.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Phase 1: UI Cleanup & Standardization
1. Modify `examination_form_screen.dart`: Remove 'THÔNG TIN HÀNH CHÍNH' and replace `followUpDate` input with `DatePicker`.
2. Modify `blood_test_prescription_screen.dart`: Remove 'THÔNG TIN CHỈ ĐỊNH' and replace `_sampleTimeCtrl` with `DateTimePicker`.

## Phase 2: Bug Fixes & Performance
1. Resolve Firestore error: Ensure `patientId` is correctly loaded before creating `TestOrder` and `Sample`.
2. Optimize saving logic: Check if serial calls in `ClinicianOrderCubit` and `ExaminationCubit` can be batched or improved.
3. Ensure proper redirection to `/clinician/dashboard` after successful save.

## Phase 3: Data Integrity & Visibility
1. Update `SharedMedicalRecordPage` to ensure `PatientInfoTab` receives all necessary patient data.
2. Update `HistoryTab` to trigger `ExaminationCubit` to load examinations for the patient if needed.
3. Verify `ManagerDashboardCubit` picks up new orders correctly.
<!-- SECTION:PLAN:END -->

