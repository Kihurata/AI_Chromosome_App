---
id: shzhpa
title: Cập nhật tính năng theo dõi thời gian thu hoạch mẫu
status: done
priority: medium
labels: []
createdAt: '2026-05-14T09:38:41.952Z'
updatedAt: '2026-05-14T09:43:11.322Z'
timeSpent: 246
assignee: '@me'
---
# Cập nhật tính năng theo dõi thời gian thu hoạch mẫu

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
1. Thêm expectedHarvestTime và actualHarvestTime vào Sample entity và SampleModel.
2. Cập nhật SampleDetailScreen: tự động tính expectedHarvestTime dựa trên Loại mẫu (Máu: 72h, Tủy xương: 48h, Dịch ối/Gai nhau: 14 ngày, Sinh thiết da: 21 ngày) tính từ collectedAt.
3. Cho phép Specialist tùy chỉnh lại expectedHarvestTime thông qua DatePicker/TimePicker.
4. Tích hợp Notification để báo cho Specialist khi sắp đến thời gian thu hoạch.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Cập nhật entity Sample và SampleModel để lưu trữ expectedHarvestTime và actualHarvestTime
- [x] #2 Thêm phần UI hiển thị và cho phép chỉnh sửa expectedHarvestTime trong SampleDetailScreen
- [x] #3 Tự động tính toán expectedHarvestTime khi thay đổi Loại mẫu hoặc Thời gian lấy mẫu
- [x] #4 Tích hợp NotificationFactory cảnh báo thời gian thu hoạch
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Model Update**: 
   - Sửa file `lib/domain/entities/sample.dart` để thêm `DateTime? expectedHarvestTime` và `DateTime? actualHarvestTime`.
   - Sửa file `lib/data/models/sample_model.dart` để parse 2 trường này từ Firestore (map với `expected_harvest_time` và `actual_harvest_time`).
2. **UI Update (SampleDetailScreen)**:
   - Trong `lib/presentation/screens/specialist/sample_detail_screen.dart`, thêm biến `_expectedHarvestDate` và `_expectedHarvestTime`.
   - Viết logic `_calculateExpectedHarvestTime(sampleType, collectedAt)` để tự động gán giá trị khi user chọn xong "Loại mẫu" và "Ngày giờ lấy mẫu".
   - Thêm UI Section hiển thị DatePicker và TimePicker cho "Thời gian thu hoạch dự kiến" để Specialist có thể chỉnh sửa thủ công.
3. **Logic Update**:
   - Khi gọi `_submitSample`, gom các thông tin này vào object `Sample` và lưu xuống Firestore thông qua `SampleDetailCubit`.
4. **Notification**:
   - Tích hợp gọi `NotificationFactory.instance.showNotification` (trong một logic timer hoặc poll định kỳ ở Dashboard) khi có mẫu sắp đến giờ `expectedHarvestTime`.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented expectedHarvestTime calculation in SampleDetailScreen, updated Sample and SampleModel to persist it. Added a timer in SampleManagementCubit to show an info notification when a sample is close to harvest.
<!-- SECTION:NOTES:END -->

