---
title: 'Frontend UI Standardization & New Roles Implementation'
description: Spec for standardizing presentation layer, DataTables, and adding Manager/Specialist UI
createdAt: '2026-05-01T06:33:40.708Z'
updatedAt: '2026-05-01T06:33:40.708Z'
tags: []
---

## Functional Requirements

### FR-1: Presentation Architecture Refactor
- Reuse Layouts: Wrap new screens in `MainFormLayout` or `MainListLayout`.
- Atomic Widgets: Use `presentation/widgets/shared/form` for inputs.
- Reactive Binding: Use `BlocListener` for one-time events (snackbars, navigation), `BlocBuilder` for UI rebuilding.
- No direct API/Firestore calls in UI layer.

### FR-2: Table Standardization
- Standardize DataTable styling across all list screens.
- Add 'Thao tác' column as the last column.
- Replace vertical 3-dots with specific icon buttons.

### FR-3: Receptionist UI Updates
- Patient List: Click row does NOT navigate. Add Eye icon (navigate to EMR). Add Pen icon (edit patient).
- Appointment List: Convert to standard DataTable. Add Eye icon in 'Thao tác' column.

### FR-4: Clinician UI Updates
- Appointment List: Add Stethoscope icon (start exam, state -> checked-in), Pen icon (edit info), Eye icon (view EMR).
- EMR Screens: Add 'Lập Phiếu Khám bệnh' button linking to `examination_form_screen.dart`.
- New Screens: Implement 'Lịch sử Khám bệnh' and 'Kết quả Xét nghiệm' based on provided designs.

### FR-5: Manager UI Implementation
- Screens: 'Danh sách Ca Xét nghiệm' and 'Duyệt Kết quả Xét nghiệm'.

### FR-6: Specialist UI Implementation
- Screens: 'Danh sách Ca Xét nghiệm được giao' and 'Ca Xét nghiệm Chi tiết' (managing multiple samples).

## Acceptance Criteria
- AC-1: All lists use `MainListLayout` and have consistent table styles.
- AC-2: Receptionist and Clinician actions match specifications without row-click navigation.
- AC-3: New EMR button navigates correctly.
- AC-4: Manager and Specialist screens are built and wired to Logic layer (no direct API calls).
