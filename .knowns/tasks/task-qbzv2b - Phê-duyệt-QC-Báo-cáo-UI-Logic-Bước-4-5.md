---
id: qbzv2b
title: 'Phê duyệt QC & Báo cáo (UI/Logic) - Bước 4 & 5'
status: done
priority: medium
labels:
  - ui
  - logic
  - workspace
createdAt: '2026-04-29T15:03:17.921Z'
updatedAt: '2026-04-29T18:13:28.404Z'
timeSpent: 138
spec: specs/specialist-workspace
fulfills:
  - FR-4
  - FR-5
  - AC-5
---
# Phê duyệt QC & Báo cáo (UI/Logic) - Bước 4 & 5

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Triển khai màn hình Bước 4 (Nhập chẩn đoán với AI suggestion panel) và Bước 5 (Form báo cáo cuối). Cập nhật trạng thái phiếu thành 'waitingApproval' và điều hướng quay lại Dashboard khi bấm Submit.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Create `QcDiagnosticStep` (Bước 4) widget for ISCN formula input and diagnostic remarks.
2. Create `ReportStep` (Bước 5) widget with a summary and a Submit button.
3. Add `submitAnalysis` method to `WorkspaceCubit` which updates the order status to `waitingApproval`.
4. Include both steps in `WorkspaceScreen` and route back to Dashboard on success.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented QcDiagnosticStep (Step 4) and ReportStep (Step 5). Created SubmitAnalysisResult usecase and wired it to WorkspaceCubit to submit the order status. Fixed router issue from previous task.
<!-- SECTION:NOTES:END -->

