---
id: 8bajal
title: 'Clinician Data & Logic Layer Implementation'
status: done
priority: high
labels:
  - domain
  - data
  - logic
  - clinician
createdAt: '2026-04-27T07:32:06.737Z'
updatedAt: '2026-04-27T07:40:00.238Z'
timeSpent: 163
---
# Clinician Data & Logic Layer Implementation

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement the Domain, Data, and Logic layers for the Clinician role. This includes managing Test Orders and physical Samples, allowing Clinicians to assign patients and transfer samples to the lab.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Update/Create `TestOrder` and `Sample` entities/models with `fromEntity` and `toModel` factories.
- [x] #2 Implement `TestOrderRepository` (`createTestOrder`, `getTestOrdersByClinician`).
- [x] #3 Implement `SampleRepository` (`createSample`, `updateSampleStatus`).
- [x] #4 Implement Usecases: `CreateGeneticTestOrder`, `CollectPhysicalSample`, `TransferSampleToLab`.
- [x] #5 Implement `ClinicianOrderCubit` to handle state management for order creation and sample updates.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Created TestOrder + Sample domain entities with status enums (fromString + toFirestoreString). Updated TestOrderModel with fromEntity factory. Created SampleModel (fromFirestore, toFirestore, fromEntity). Created TestOrderRemoteDataSource + FirebaseImpl, SampleRemoteDataSource + FirebaseImpl. Created domain interfaces TestOrderRepository + SampleRepository. Created TestOrderRepositoryImpl + SampleRepositoryImpl. Created 3 usecases: CreateGeneticTestOrder, CollectPhysicalSample, TransferSampleToLab. Created ClinicianOrderCubit (submitTestOrder, collectSample, transferToLab) + ClinicianOrderState. dart analyze: No issues found on all 15 new files.
<!-- SECTION:NOTES:END -->

