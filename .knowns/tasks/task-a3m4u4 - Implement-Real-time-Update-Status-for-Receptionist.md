---
id: a3m4u4
title: 'Implement Real-time & Update Status for Receptionist Appointments (Data/Logic)'
status: done
priority: high
labels:
  - data
  - domain
  - logic
  - receptionist
  - real-time
createdAt: '2026-04-27T17:00:54.777Z'
updatedAt: '2026-04-27T17:12:22.886Z'
timeSpent: 677
assignee: '@me'
---
# Implement Real-time & Update Status for Receptionist Appointments (Data/Logic)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement `watchTodayAppointments` (Stream) and `updateAppointmentStatus` in the Data (DataSource, Repository), Domain (Usecases), and Logic (AppointmentCubit) layers to support real-time updates and status transitions for the Receptionist. The UI layer is explicitly excluded from this task.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Update AppointmentRemoteDataSource with `watchTodayAppointments` and `updateAppointmentStatus`
- [x] #2 Update AppointmentRepository interface and Implementation
- [x] #3 Create Usecases: `WatchTodayAppointments` and `UpdateAppointmentStatus`
- [x] #4 Update AppointmentCubit with `listenToTodayAppointments` and `updateStatus`
- [x] #5 Run dart analyze to verify Data, Domain, and Logic layers
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Update Data Source: Add `watchTodayAppointments` (returns `Stream<List<AppointmentModel>>`) and `updateAppointmentStatus` to `AppointmentRemoteDataSource` and its Firebase implementation.
2. Update Repository: Add the equivalent methods to `AppointmentRepository` and `AppointmentRepositoryImpl`, mapping Models to Entities via `_modelToEntity`.
3. Create Usecases: Implement `WatchTodayAppointments` (returns `Stream<Either<Failure, List<Appointment>>>`) and `UpdateAppointmentStatus` (returns `Future<Either<Failure, void>>`).
4. Update Logic: Modify `AppointmentCubit` to inject the new usecases. Implement `listenToTodayAppointments` using `emit.forEach` and `updateStatus`.
5. Verify: Run `dart analyze` on the modified files to ensure correctness.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
AC1+2 done: Added watchTodayAppointments (Stream) and updateAppointmentStatus to DataSource, Repository interface, and RepositoryImpl.
AC3+4 done: Created WatchTodayAppointments and UpdateAppointmentStatus usecases. Updated AppointmentCubit with listenToTodayAppointments (emit.forEach) and updateStatus.
AC5 done: dart analyze passes on all 6 target files with no issues. Fixed emit.forEach → await for loop (correct Cubit Stream pattern in flutter_bloc).
<!-- SECTION:NOTES:END -->

