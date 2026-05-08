---
id: lmwdsa
title: Refining Dashboard and Sample Workflow
status: done
priority: medium
labels: []
createdAt: '2026-05-08T04:29:16.977Z'
updatedAt: '2026-05-08T04:31:18.211Z'
timeSpent: 98
assignee: '@me'
---
# Refining Dashboard and Sample Workflow

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refining Specialist/Receptionist workflows:
1. Hide 'Assign Specialist' button after assignment in Manager Dashboard.
2. Fix StatusBadge width issue in Receptionist Dashboard and Calendar (badge is too wide).
3. Implement Sample Type dropdown in Specialist Sample Detail Screen with 7 biological sample types.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 'Chỉ định BS' button is hidden if a specialist is already assigned.
- [x] #2 StatusBadge in TodayAppointmentsTable hugs content (not full width).
- [x] #3 StatusBadge in AppointmentCalendarPage hugs content (not full width).
- [x] #4 Sample Type in SampleDetailScreen is a dropdown with 7 specific types.
- [x] #5 Selecting and saving a sample type works correctly.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Update 'lab_examination_table.dart' action button visibility logic.
2. Fix StatusBadge layout in 'today_appointments_table.dart' and 'appointment_calendar_page.dart' using Align widget.
3. Replace Sample Type text/field with AppDropdown in 'sample_detail_screen.dart'.
4. Hardcode 7 biological sample types in the dropdown.
5. Verify changes in the UI.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implementation complete:
1. Updated LabExaminationTable to hide 'Assign Specialist' button if specialistId is not null.
2. Fixed StatusBadge width in TodayAppointmentsTable and AppointmentCalendarPage using Align widget.
3. Implemented Sample Type dropdown in SampleDetailScreen with 7 biological types.
4. Updated Sample creation logic to use selected dropdown value.
<!-- SECTION:NOTES:END -->

