---
id: i01tlr
title: 'Refactor Specialist UI: Dashboard Cleanup and Sample Analysis Trigger'
status: done
priority: high
labels: []
createdAt: '2026-05-07T04:00:02.755Z'
updatedAt: '2026-05-07T04:10:17.694Z'
timeSpent: 608
assignee: '@me'
---
# Refactor Specialist UI: Dashboard Cleanup and Sample Analysis Trigger

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
1. Dashboard: Xóa các nút lọc trạng thái, sắp xếp danh sách phiếu xét nghiệm mới nhất lên đầu.
2. Quản lý Mẫu: Thêm nút 'Bắt đầu Phân tích' khi mẫu ở trạng thái 'Thu hoạch thành công'. Nút này sẽ cập nhật trạng thái phiếu xét nghiệm sang 'Đang phân tích' và điều hướng tới trang Workspace.
Lưu ý: Không chỉnh sửa thêm các phần khác ngoài yêu cầu.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan: Refactor Specialist UI (Task i01tlr)

### 1. Dashboard: Cleanup & Sorting
- **File**: `frontend/lib/presentation/screens/specialist/widgets/specialist_filter_bar.dart`
    - Xóa widget `Wrap` chứa các chip lọc.
- **File**: `frontend/lib/logic/bloc/specialist/specialist_dashboard_cubit.dart`
    - Cập nhật `_applyFilters` để thực hiện `sort` danh sách theo `createdAt` giảm dần.

### 2. Sample Management: Analysis Trigger
- **File**: `frontend/lib/logic/bloc/specialist/sample_management_state.dart`
    - Thêm field `lastStartedOrderId` và logic `copyWith` tương ứng.
- **File**: `frontend/lib/logic/bloc/specialist/sample_management_cubit.dart`
    - Inject usecase `UpdateOrderStatus`.
    - Thêm method `startAnalysis(String orderId)`.
- **File**: `frontend/lib/presentation/screens/specialist/widgets/sample_card.dart`
    - Thêm nút 'Bắt đầu Phân tích' cho trạng thái `harvested`.
- **File**: `frontend/lib/presentation/screens/specialist/sample_management_page.dart`
    - Thêm `BlocListener` để xử lý điều hướng khi `lastStartedOrderId` có dữ liệu.

### 3. Verification
- Chạy `flutter analyze`.
- Kiểm tra tính đúng đắn của UI và luồng điều hướng.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Hoàn tất refactor giao diện Specialist theo yêu cầu:
1. Dashboard: Xóa các nút lọc trạng thái, chỉ giữ lại thanh tìm kiếm. Cập nhật logic sắp xếp danh sách phiếu xét nghiệm theo thời gian (mới nhất lên đầu).
2. Quản lý Mẫu: Thêm nút 'Bắt đầu Phân tích' khi mẫu ở trạng thái 'Thu hoạch thành công'. Khi bấm nút, hệ thống sẽ cập nhật trạng thái phiếu xét nghiệm sang 'Đang phân tích' và tự động điều hướng tới trang Workspace phân tích.
3. Đã cập nhật Dependency Injection (build_runner) và kiểm tra lỗi bằng flutter analyze (No issues found).
<!-- SECTION:NOTES:END -->

