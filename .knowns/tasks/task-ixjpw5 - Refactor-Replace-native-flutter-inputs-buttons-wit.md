---
id: ixjpw5
title: 'Refactor: Replace native flutter inputs/buttons with Atomic Widgets'
status: done
priority: high
labels: []
createdAt: '2026-05-02T08:43:35.770Z'
updatedAt: '2026-05-04T10:26:40.651Z'
timeSpent: 94305
assignee: '@me'
---
# Refactor: Replace native flutter inputs/buttons with Atomic Widgets

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Refactor the entire presentation layer to enforce the 'Atomic Widgets' rule. Replace all direct usages of native Flutter widgets like TextField, TextFormField, ElevatedButton, and OutlinedButton with the project's shared atomic widgets: AppTextField, AppPrimaryButton, and AppSecondaryButton. This ensures visual consistency and adheres to the project's composition-based architecture.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. Standardize LabResultReviewPage: Replace native buttons with AppPrimaryButton and AppSecondaryButton.
2. Refactor RecentPatientsTable: Consolidate action icons into a dynamic state-aware AppButton.
3. Global UI Cleanup: Search and replace remaining native TextField/Buttons across lib/presentation/.
4. Visual Verification: Ensure layout consistency and proper padding after widget replacement.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Hoàn tất chuẩn hóa toàn bộ layer Presentation sang Atomic Widgets:
1. LabResultReviewPage: Thay thế native buttons.
2. RecentPatientsTable: Hợp nhất icon thành State-aware AppButton.
3. TodayAppointmentsTable & LabExaminationTable: Chuẩn hóa các nút hành động và phân trang.
4. Workspace & Steps: Chuẩn hóa toàn bộ nút điều hướng và ô nhập liệu (ISCN, Remarks).
5. AppDataTable: Tích hợp AppTextField vào thanh tìm kiếm.
6. Specialist Dashboard & Patient Details: Thay thế các nút native còn sót lại.
<!-- SECTION:NOTES:END -->

