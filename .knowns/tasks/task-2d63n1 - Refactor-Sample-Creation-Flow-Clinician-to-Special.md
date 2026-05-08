---
id: 2d63n1
title: Refactor Sample Creation Flow (Clinician to Specialist)
status: done
priority: high
labels: []
createdAt: '2026-05-07T10:12:17.941Z'
updatedAt: '2026-05-07T10:23:30.795Z'
timeSpent: 285
---
# Refactor Sample Creation Flow (Clinician to Specialist)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor the sample creation flow. Shift the responsibility of creating a Sample from Clinician to Specialist. Update Clinician form to only create TestOrder. Update Specialist dashboard to have a "Tạo Mẫu" button for PENDING orders. Refactor SampleDetailScreen into a sample creation form with UI matching the old Clinician form. Ensure new samples appear in SampleManagementPage.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Refactor blood_test_prescription_screen.dart to only submit TestOrder
- [x] #2 Change button to 'Tạo Mẫu' in specialist_order_card.dart for pending orders
- [x] #3 Refactor sample_detail_screen.dart to be a form for creating SampleModel
- [x] #4 Implement createSample logic in SampleDetailCubit
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

1. **Refactor Clinician Form (`blood_test_prescription_screen.dart`)**
   - Remove `_selectedDate`, `_selectedTime`, and `_clinicalNotesCtrl` inputs from the UI.
   - Update `_submitOrder(context)` to only instantiate a `TestOrder` (without a `Sample`).
   - Call `ClinicianOrderCubit.createOrder` instead of `submitOrderWithSample`.
   - Simplify the layout so it just confirms the creation of a "Phiếu Chỉ Định".

2. **Update Specialist Order Card (`specialist_order_card.dart`)**
   - For `TestOrderStatus.pending`, change the button label to **"Tạo Mẫu"** and change the icon (e.g., `LucideIcons.flaskConical`).
   - Remove the `_showStartAnalysisConfirm` popup for `pending` status.
   - When clicked, keep the existing navigation logic `context.pushNamed('specialist-sample-detail', pathParameters: {'id': order.id})` (which will now be used for sample creation).

3. **Refactor Sample Detail Screen (`sample_detail_screen.dart`)**
   - Migrate UI to use `MainFormLayout`, removing the read-only display.
   - Add DatePicker and TimePicker (reused code from the old clinician form).
   - Add a TextField for Clinical Notes.
   - Load the `TestOrder` via `SpecialistDashboardCubit` (or route extra) to extract `patientName` and `patientCode`.
   - On save, construct a new `SampleModel` with `sampleType: 'Máu'`, the selected date/time, notes, and hardcoded status `SampleStatus.collected`.
   - Trigger `SampleDetailCubit.createSample(...)` to save data to Firestore.
   - On success, return to the dashboard (`context.pop()`).

4. **Update Sample Detail Cubit (`sample_detail_cubit.dart`)**
   - Add `CollectPhysicalSample` usecase as a dependency.
   - Implement `createSample(Sample sample)` which emits loading state, executes the usecase, and emits success/error states.
   - Ensure the dependency is properly registered in DI (`injection.dart`).

5. **Verify Sample Management Page**
   - `SampleManagementPage` uses a stream via `SampleManagementCubit`, so new samples will automatically appear without code changes. Test this to be certain.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Refactored clinician form to only create TestOrder. Updated specialist card button to 'Tạo Mẫu'. Refactored SampleDetailScreen into a creation form. Created GetTestOrderById usecase and updated SampleDetailCubit. Running build_runner to update DI.
<!-- SECTION:NOTES:END -->

