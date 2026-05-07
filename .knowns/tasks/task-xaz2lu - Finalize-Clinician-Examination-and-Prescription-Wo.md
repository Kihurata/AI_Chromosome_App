---
id: xaz2lu
title: Finalize Clinician Examination and Prescription Workflow
status: done
priority: high
labels: []
createdAt: '2026-05-04T04:19:09.421Z'
updatedAt: '2026-05-04T04:25:42.449Z'
timeSpent: 387
assignee: '@me'
---
# Finalize Clinician Examination and Prescription Workflow

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
- Update examination_form_screen.dart to capture and save all clinical fields.
- Refactor blood_test_prescription_screen.dart to remove non-model fields and implement atomic creation of TestOrder and Sample.
- Map TestOrderStatus.pending to 'Chờ chỉ định' on all UI components.
- Enhance history_tab.dart to display full examination details in expanded view.
- Ensure adherence to existing models (TestOrderModel, SampleModel, ExaminationModel) without structural changes.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 examination_form_screen.dart saves all 13 fields correctly to Firestore via Cubit.
- [x] #2 blood_test_prescription_screen.dart removed 'Test Type' and 'Sample Type' fields to match models.
- [x] #3 blood_test_prescription_screen.dart creates both TestOrder and Sample atomically in Firestore.
- [x] #4 history_tab.dart displays all detailed clinical fields in the expanded view.
- [ ] #5 TestOrderStatus.pending remains 'Chờ xử lý' as per user request.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Completed clinical workflow refinement.
- Updated examination form to save 13 fields.
- Enhanced history tab with detailed clinical views.
- Implemented atomic saving for test orders and samples in ClinicianOrderCubit.
- Cleaned up prescription form UI to align with models.
<!-- SECTION:NOTES:END -->

