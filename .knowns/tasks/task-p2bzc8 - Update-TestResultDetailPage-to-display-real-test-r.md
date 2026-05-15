---
id: p2bzc8
title: Update TestResultDetailPage to display real test results
status: done
priority: high
labels: []
createdAt: '2026-05-08T07:31:12.041Z'
updatedAt: '2026-05-14T10:03:43.797Z'
timeSpent: 1053
assignee: '@me'
---
# Update TestResultDetailPage to display real test results

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Cập nhật màn hình `TestResultDetailPage` (route `/clinician/test-result/:id`) để lấy kết quả xét nghiệm thực tế (báo cáo Quill và bộ NST) thay vì sử dụng dữ liệu tĩnh (hardcoded).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Create `TestResultDetailCubit` to load `TestOrder` and `chromosomes`.
- [x] #2 Update `app_router.dart` to provide the cubit to `TestResultDetailPage`.
- [x] #3 Refactor `TestResultDetailPage` to display dynamic patient info.
- [x] #4 Use `flutter_quill` read-only to display `reportContent`.
- [x] #5 Use `KaryotypeGrid` to display chromosomes.
- [x] #6 Data Accuracy: Cross-verify all UI fields (patientName, patientCode, status, reportContent) with TestOrder entity.
- [x] #7 Data Accuracy: Ensure Chromosome list properties (imageUrl, label) are mapped correctly in the Grid.
- [x] #8 UI Polish: Apply Design System tokens (AppColors.primaryBlue, AppColors.textSecondary) consistently.
- [x] #9 Interactive UI: Add a simple tap-to-zoom dialog for chromosomes using existing data.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Revised Implementation Plan (Focus: Accuracy \u0026 Existing Data)
1. **Property Audit**:
   - Review `test_result_detail_page.dart` and ensure all data access uses fields from `TestOrder` and `Chromosome` entities.
   - Use `order.patientName`, `order.patientCode`, `order.id`, `order.createdAt`, and `order.status.displayName`.
2. **Karyotype Zoom**:
   - Wrap `KaryotypeGrid` with a widget that detects taps.
   - Implement `_showChromosomePreview(Chromosome c)` using `showDialog` to display the `imageUrl` and `label`.
3. **UI Finalization**:
   - Ensure `AppCard` and `BaseLayout` are used for consistent spacing and shadows.
   - Check text styles against the `UI Design System` (Page Title 24px, Card Titles 16px).
4. **Validation**:
   - Run `dart analyze` to ensure no property naming errors.
   - Verify the screen loads and displays all data for a completed order.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created TestResultDetailCubit and state files. Running build_runner for DI.
Implementation complete. Refactored TestResultDetailPage and created TestResultDetailCubit. Build runner completed successfully.
Reopened to expand UI features and ensure data property alignment with the Data layer.
Revised plan: Focus on data accuracy and UI polish using existing fields. Removed new data fetching requirements (Audit Trail).
UI polish complete: replaced dynamic with TestOrder/Chromosome types, added AppCard padding, added tappable karyotype cells with zoom dialog, added rejected status handling in approval widget. dart analyze: No issues found.
<!-- SECTION:NOTES:END -->

