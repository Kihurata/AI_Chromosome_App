---
id: jsre7s
title: Implement Clinician Tracking and Robust Backend ID Extraction
status: done
priority: high
labels: []
createdAt: '2026-05-06T07:46:07.032Z'
updatedAt: '2026-05-06T08:38:25.946Z'
timeSpent: 0
assignee: '@me'
spec: specs/notification-system-expansion
---
# Implement Clinician Tracking and Robust Backend ID Extraction

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement clinician_id tracking in test_orders and enhance backend ID extraction.
1. Add clinician_id field to TestOrder entity and TestOrderModel.
2. Update Firestore saving logic in ClinicianBloodTestPrescriptionPage and ClinicianOrderCubit.
3. Update backend firestore_listener.py to robustly handle DocumentReference types in get_id.
4. Verify notification delivery for ORDER_COMPLETED status.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 TestOrder entity has clinicianId field.
- [x] #2 TestOrderModel includes clinician_id as DocumentReference in Firestore.
- [x] #3 Blood test saving logic correctly populates clinician_id from Auth state.
- [x] #4 Backend get_id function is robust against different Python Firebase SDK versions.
- [x] #5 ORDER_COMPLETED notification successfully reaches the clinician.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan - Task jsre7s

### 1. Update Domain Entity
- Add `clinicianId` (String) to `TestOrder` entity in `frontend/lib/domain/entities/test_order.dart`.

### 2. Update Data Model
- Add `clinicianId` (DocumentReference) to `TestOrderModel` in `frontend/lib/data/models/test_order_model.dart`.
- Update `toFirestore`, `fromFirestore`, and `fromEntity` methods to handle `clinician_id`.

### 3. Update Frontend Saving Logic
- Update `_submitOrder` in `ClinicianBloodTestPrescriptionPage` to pass `clinicianId` from `AuthCubit` to the `TestOrder` constructor.
- Update `ClinicianOrderCubit` if necessary (though it just passes the entity through).

### 4. Enhance Backend Robustness
- Modify `get_id` in `backend/app/services/firestore_listener.py`.
- Use `isinstance(value, DocumentReference)` or check for `.path` / `.id` more safely to ensure compatibility with various types of Firestore references.

### 5. Verification
- Create a test order as a Clinician.
- Manager approves the order.
- Verify that the Clinician receives the `ORDER_COMPLETED` notification and hears the sound.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: 
1. Added clinicianId to TestOrder entity and mapped it in Equatable.
2. Updated TestOrderModel to handle clinician_id as DocumentReference in both directions (to/from Firestore).
3. Updated TestOrderRepositoryImpl to map clinicianId in _modelToEntity.
4. Updated ClinicianBloodTestPrescriptionPage to populate clinicianId from Auth state during order creation.
5. Enhanced get_id helper in backend firestore_listener.py for better robustness.
<!-- SECTION:NOTES:END -->

