---
id: fpa40g
title: Extract getClinicians to ClinicianRepository
status: done
priority: medium
labels: []
createdAt: '2026-04-27T07:09:57.463Z'
updatedAt: '2026-04-27T07:11:36.591Z'
timeSpent: 88
assignee: '@me'
---
# Extract getClinicians to ClinicianRepository

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Extract getClinicians from AppointmentRepository to a dedicated ClinicianRepository to adhere to the Single Responsibility Principle and Clean Architecture.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. **Extract Data Source**: Create `lib/data/datasources/clinician_remote_datasource.dart`. Move the `getClinicians` logic from `AppointmentRemoteDataSource` to this new class, and remove it from `AppointmentRemoteDataSource`.
2. **Create ClinicianRepository**: Create `lib/domain/repositories/clinician_repository.dart` (interface) and `lib/data/repositories/clinician_repository_impl.dart` (implementation). Remove `getClinicians` from `AppointmentRepository` and `AppointmentRepositoryImpl`.
3. **Move Usecase**: Move `lib/domain/usecases/appointment/get_clinicians.dart` to `lib/domain/usecases/clinician/get_clinicians.dart`. Update its dependency to use `ClinicianRepository` instead of `AppointmentRepository`.
4. **Update Cubit**: Update `lib/logic/bloc/appointment/appointment_cubit.dart` to import `GetClinicians` from the new folder.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Bóc tách thành công hàm getClinicians sang ClinicianRepository, tạo mới ClinicianRemoteDataSource, và dời Usecase sang thư mục clinician.
<!-- SECTION:NOTES:END -->

