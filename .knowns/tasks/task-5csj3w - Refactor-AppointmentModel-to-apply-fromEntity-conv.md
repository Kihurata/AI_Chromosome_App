---
id: 5csj3w
title: Refactor AppointmentModel to apply fromEntity convention
status: done
priority: medium
labels: []
createdAt: '2026-04-27T06:59:33.261Z'
updatedAt: '2026-04-27T07:00:59.449Z'
timeSpent: 75
assignee: '@me'
---
# Refactor AppointmentModel to apply fromEntity convention

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor AppointmentModel to include a `factory AppointmentModel.fromEntity(Appointment appointment)` method according to the new convention. Update AppointmentRepositoryImpl to use this new factory method.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. **Update AppointmentModel**: Open `lib/data/models/appointment_model.dart` and add `factory AppointmentModel.fromEntity(Appointment appointment)`. It will import `cloud_firestore` and the `Appointment` entity to map `patientId` and `doctorId` strings back to Firestore `DocumentReference` objects.
2. **Refactor AppointmentRepositoryImpl**: Open `lib/data/repositories/appointment_repository_impl.dart`. Delete the custom `_entityToModel(Appointment appointment)` method. Update the `createAppointment` method to call `AppointmentModel.fromEntity(appointment)` instead of using the custom method.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Added factory AppointmentModel.fromEntity and updated AppointmentRepositoryImpl.
<!-- SECTION:NOTES:END -->

