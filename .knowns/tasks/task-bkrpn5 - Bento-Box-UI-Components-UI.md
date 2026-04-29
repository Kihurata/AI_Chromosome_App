---
id: bkrpn5
title: Bento Box UI Components (UI)
status: done
priority: medium
labels: []
createdAt: '2026-04-29T09:14:45.577Z'
updatedAt: '2026-04-29T14:01:26.449Z'
timeSpent: 0
spec: specs/specialist-dashboard
fulfills:
  - FR-1
  - AC-1
---
# Bento Box UI Components (UI)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Xây dựng Widget hiển thị các ô thống kê (Bento Box) dựa trên dữ liệu từ Cubit. Phụ thuộc vào @task-fk1mqa.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng UI 4 card Bento Box với màu sắc và icons theo status
- [x] #2 Binding dữ liệu stats từ SpecialistDashboardCubit
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented SpecialistBentoStats with real-time data binding. Refined SpecialistStats entity with a total getter. Validation passed with 0 errors.
<!-- SECTION:NOTES:END -->

