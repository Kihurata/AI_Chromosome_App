---
id: v2q5pk
title: Sửa lỗi không cập nhật Header khi back về Dashboard
status: done
priority: medium
labels:
  - bug
  - navigation
createdAt: '2026-05-14T07:31:56.949Z'
updatedAt: '2026-05-14T07:54:20.416Z'
timeSpent: 1339
assignee: '@me'
---
# Sửa lỗi không cập nhật Header khi back về Dashboard

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Khi dùng pushNamed để sang trang chi tiết, trang Dashboard không bị hủy. Khi pop về, Dashboard không rebuild nên Header giữ nguyên tiêu đề của trang chi tiết. Cần cập nhật lại Header sau khi pushNamed hoàn thành.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Chuyển đổi SpecialistOrderCard thành ConsumerWidget thành công
- [x] #2 Cập nhật Header về trạng thái Dashboard sau khi back từ trang chi tiết
- [x] #3 Không có lỗi lint hay compile
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan
1. **Convert SpecialistOrderCard to ConsumerWidget**: Chuyển đổi `specialist_order_card.dart` từ `StatelessWidget` sang `ConsumerWidget` để có thể sử dụng `ref`.
2. **Update navigation logic in SpecialistOrderCard**:
   - Thêm `await` trước `context.pushNamed(...)` trong callback `onTap`.
   - Sau khi `await` hoàn tất, sử dụng `ref.read(authNotifierProvider)` để lấy tên người dùng.
   - Gọi `ref.read(headerProvider.notifier).update(...)` để khôi phục tiêu đề 'Bảng điều khiển' và phụ đề 'Chào mừng trở lại, ...'.
3. **Verify**: Kiểm tra luồng điều hướng và đảm bảo Header hiển thị đúng sau khi back.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: Converted SpecialistOrderCard to ConsumerWidget and updated onTap to restore header state.
<!-- SECTION:NOTES:END -->

