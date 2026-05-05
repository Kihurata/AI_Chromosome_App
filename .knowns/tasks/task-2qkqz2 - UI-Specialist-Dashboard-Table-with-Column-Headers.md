---
id: 2qkqz2
title: 'UI: Specialist Dashboard Table with Column Headers'
status: done
priority: high
labels:
  - from-spec
  - go-mode
  - ui
createdAt: '2026-05-05T16:08:26.977Z'
updatedAt: '2026-05-05T16:09:30.667Z'
timeSpent: 0
spec: specs/specialist-dashboard-table-ui
fulfills:
  - AC-1
  - AC-2
  - AC-3
  - AC-4
---
# UI: Specialist Dashboard Table with Column Headers

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor SpecialistOrderList and SpecialistOrderCard to show a table with header row (Bệnh nhân, Xét nghiệm, Ngày yêu cầu, Hành động) with center-aligned content.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Add sticky header row to SpecialistOrderList
- [x] #2 Refactor SpecialistOrderCard to table-row layout, all cells centered
- [x] #3 Preserve click-to-detail and action button behavior
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Refactored order list to table with header row and centered cells. Preserved click-to-detail and action buttons.
<!-- SECTION:NOTES:END -->

