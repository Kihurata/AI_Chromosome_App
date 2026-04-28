---
id: qwwtrg
title: Implement Domain and Logic for Appointment Module
status: done
priority: high
labels: []
createdAt: '2026-04-27T06:48:01.278Z'
updatedAt: '2026-04-27T06:51:34.097Z'
timeSpent: 201
assignee: '@me'
---
# Implement Domain and Logic for Appointment Module

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement missing Domain and Logic layers for the Appointment module in Receptionist flow.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. **Domain Layer - Entity & Repository Interface**: Create `lib/domain/entities/appointment.dart` based on fields from `AppointmentModel` and `lib/domain/repositories/appointment_repository.dart` interface.
2. **Data Layer - Repository Implementation**: Create `lib/data/repositories/appointment_repository_impl.dart` to map `AppointmentModel` to `Appointment` entity and handle Failures via `dartz`.
3. **Domain Layer - Usecases**: Create 3 usecases (`create_appointment.dart`, `get_today_appointments.dart`, `get_clinicians.dart`) inside `lib/domain/usecases/appointment/`.
4. **Logic Layer - Cubit & State**: Create `lib/logic/bloc/appointment/appointment_cubit.dart` and `appointment_state.dart` to manage UI states for the Receptionist appointment flow.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Implemented Appointment entity, AppointmentRepository, AppointmentRepositoryImpl, Usecases (CreateAppointment, GetTodayAppointments, GetClinicians), and AppointmentCubit. Note: 'dart analyze' shows errors in the presentation layer because it still incorrectly imports a non-existent 'ClinicalRepository' and bypasses Clean Architecture. A new task should be created to refactor the Receptionist UI to use the new AppointmentCubit and PatientCubit.
<!-- SECTION:NOTES:END -->

