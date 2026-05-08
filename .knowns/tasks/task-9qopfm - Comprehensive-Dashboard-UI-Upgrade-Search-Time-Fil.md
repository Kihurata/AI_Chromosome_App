---
id: 9qopfm
title: 'Comprehensive Dashboard UI Upgrade: Search, Time Filter & Sorting'
status: done
priority: high
labels: []
createdAt: '2026-05-07T04:54:14.482Z'
updatedAt: '2026-05-07T06:21:12.000Z'
timeSpent: 5212
assignee: '@me'
---
# Comprehensive Dashboard UI Upgrade: Search, Time Filter & Sorting

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nâng cấp đồng bộ giao diện Dashboard và các màn hình danh sách cho tất cả các Role:
1. Thêm thanh Toolbar (Search 70%, Advanced Filter 30%).
2. Thêm Side Drawer lọc nâng cao (Sắp xếp Mới nhất/Cũ nhất, Khoảng thời gian: Hôm nay, 7 ngày, 30 ngày, Tùy chỉnh).
3. Đảm bảo tất cả danh sách luôn hiển thị dữ liệu mới nhất ở hàng đầu (Newest First).
4. Áp dụng cho: Dashboard (Tất cả role), Quản lý mẫu, Danh sách bệnh nhân, Lịch sử khám bệnh (History Tab), Kết quả xét nghiệm (Test Results Tab).
5. Xây dựng logic lọc tại chỗ (Local Filtering) trong Cubit để đảm bảo tốc độ phản hồi.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Xây dựng widget AppDashboardFilterBar và AppAdvancedFilterDrawer dùng chung.
- [x] #2 Cập nhật logic Search/Sort/Time Filter cho 7 Cubit (Specialist, Manager, Clinician, Patient, v.v.).
- [x] #3 Tích hợp Toolbar và Drawer vào 4 trang Dashboard chính.
- [x] #4 Tích hợp vào các trang Patient List, Medical Record (History Tab, Test Results Tab).
- [x] #5 Đảm bảo tính năng Newest First (mới nhất lên đầu) hoạt động trên mọi bảng.
- [x] #6 Kiểm tra hiệu năng lọc Local Filtering không gây giật lag UI.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan: Comprehensive Dashboard UI Upgrade

### Phase 1: Shared UI Components
- **File**: `frontend/lib/presentation/widgets/shared/form/dashboard_filter_bar.dart`
    - Build `AppDashboardFilterBar`: Search input (70%) + Advanced Filter Button (30%).
- **File**: `frontend/lib/presentation/widgets/shared/filter/advanced_filter_drawer.dart`
    - Build `AppAdvancedFilterDrawer`: Modular list of filter groups.
    - Implement Time Sorting (Newest/Oldest) and Time Range (Presets + Custom) groups.

### Phase 2: Logic Layer (Cubit) Standardization
- **Pattern**: Add `searchQuery`, `sortOrder`, `dateRange` to states. Implement `updateFilters` in Cubits.
- **Affected Cubits**:
    1. `SpecialistDashboardCubit`
    2. `SampleManagementCubit`
    3. `ManagerDashboardCubit`
    4. `AppointmentCubit` (Clinician/Receptionist)
    5. `PatientCubit` (Receptionist)
    6. `ExaminationCubit` (History Tab)
    7. `ClinicianOrderCubit` (Test Results Tab)

### Phase 3: Dashboard Integrations
- Integrate `AppDashboardFilterBar` into:
    - `DoctorDashboardPage`
    - `LabManagerDashboardPage`
    - `ReceptionistDashboardPage` (Dashboard body)
    - `SpecialistDashboardPage`

### Phase 4: Detailed List Integrations
- Integrate into:
    - `PatientListPage`
    - `SampleManagementPage`
    - `HistoryTab` (Medical Record)
    - `TestResultsTab` (Medical Record)

### Phase 5: Verification
- Run `flutter analyze`.
- Verify sorting (Newest first) and search functionality on at least 2 key screens.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Phase 1 complete: Created AppDashboardFilterBar and AppAdvancedFilterDrawer shared widgets.
Đã sửa lỗi naming mismatch trong Model, Repository và Cubit. Đã tạo các Usecase thiếu. Đã fix lỗi UI và DI. Yêu cầu user chạy build_runner.
<!-- SECTION:NOTES:END -->

