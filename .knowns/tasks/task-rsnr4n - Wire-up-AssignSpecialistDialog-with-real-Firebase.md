---
id: rsnr4n
title: Wire up AssignSpecialistDialog with real Firebase data
status: done
priority: high
labels: []
createdAt: '2026-05-06T07:21:08.886Z'
updatedAt: '2026-05-06T07:22:29.725Z'
timeSpent: 76
spec: specs/manager-dashboard
---
# Wire up AssignSpecialistDialog with real Firebase data

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Connect AssignSpecialistDialog to real specialist data from ManagerDashboardCubit/State. Replace mock data in the dialog with actual data from Firestore.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 AssignSpecialistDialog accepts a list of Specialist entities.
- [x] #2 Mock data is removed from AssignSpecialistDialog.
- [x] #3 LabExaminationTable passes real specialists from ManagerDashboardState to the dialog.
- [x] #4 UI displays real names and active workload from the Specialist entity.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Update `AssignSpecialistDialog` to accept `List<Specialist> specialists` in its constructor and remove mock data.
2. Update `AssignSpecialistDialog` UI to map `Specialist` properties (fullName, activeWorkload) to the list items.
3. Update `LabExaminationTable` to receive the specialist list as a parameter and pass it to `AssignSpecialistDialog`.
4. Verify that the "Chỉ định BS" button in `LabManagerDashboardPage` now triggers the dialog with real data.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Kết nối thành công AssignSpecialistDialog với dữ liệu thật từ ManagerDashboardCubit. Đã xóa mock data và cập nhật UI để hiển thị tên và workload thật từ Firestore.
<!-- SECTION:NOTES:END -->

