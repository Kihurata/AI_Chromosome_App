## Overview

Specification cho màn hình "Bước 2: Phân loại - Tách NST (Đồng bộ Sidebar Header)". Màn hình này là bước tiếp theo sau khi sàng lọc hình ảnh (Bước 1), cho phép Chuyên viên (Specialist) tách các cụm NST dính nhau và sắp xếp lại các NST vào đúng vị trí trên lưới Karyotype dựa trên kết quả gợi ý ban đầu của AI.

## Locked Decisions

- **D1**: Sử dụng công cụ vẽ đường bao quanh (Polygon Lasso) để chọn và tách thủ công các NST bị chồng chéo/dính nhau.
- **D2**: Sử dụng thao tác Kéo và Thả (Drag & Drop) để điều chỉnh và sửa lỗi phân loại vị trí các NST trên lưới Karyotype.
- **D3**: Mọi thao tác chỉnh sửa (cắt, kéo thả) sẽ chỉ thay đổi trạng thái ở Local State (Cubit) để đảm bảo UI phản hồi tức thì. Dữ liệu chỉ được đẩy lên Firestore khi user bấm nút "Lưu nháp" (Save Draft) hoặc "Hoàn thành bước 2".

## Requirements

### Functional Requirements

- **FR-1**: Màn hình phải hiển thị hai khu vực chính: Khu vực danh sách các NST chưa phân loại / bị dính (Unclassified Pool) và Khu vực lưới Karyotype (các cặp từ 1-22, X, Y).
- **FR-2**: Người dùng có thể chọn công cụ Polygon Lasso. Khi ở chế độ này, người dùng có thể vẽ một đường khép kín quanh một NST trong cụm dính. Phần được khoanh sẽ tách thành một đối tượng NST độc lập mới.
- **FR-3**: Người dùng có thể kéo thả (Drag & Drop) một NST từ Unclassified Pool vào bất kỳ ô nào trên lưới Karyotype, hoặc di chuyển từ ô này sang ô khác trên lưới.
- **FR-4**: Cung cấp nút "Lưu nháp" để lưu trạng thái làm việc hiện tại lên Firestore.
- **FR-5**: Cung cấp nút "Hoàn thành" để xác nhận lưu kết quả và chuyển sang Bước 3 (Lập NST đồ).
- **FR-6**: Màn hình phải sử dụng các thành phần bố cục chung (AppHeader và AppSideRail) theo chuẩn "Đồng bộ Sidebar Header".

### Non-Functional Requirements

- **NFR-1**: Hiệu năng kéo thả (Drag & Drop) và vẽ Lasso phải mượt mà (mục tiêu 60fps), không bị giật lag khi thao tác trên hình ảnh NST độ phân giải cao.

## Acceptance Criteria

- [ ] AC-1: Giao diện hiển thị đúng 2 khu vực: Unclassified Pool và lưới Karyotype chuẩn.
- [ ] AC-2: Có thể vẽ Lasso quanh một vùng ảnh và tách vùng đó thành ảnh riêng biệt thành công.
- [ ] AC-3: Có thể kéo thả một NST từ ô số 1 sang ô số 2, và UI cập nhật vị trí ngay lập tức.
- [ ] AC-4: Khi thao tác cắt, kéo thả, hệ thống KHÔNG gọi API tự động. API/Firestore chỉ được gọi khi bấm "Lưu nháp" hoặc "Hoàn thành".
- [ ] AC-5: Màn hình sử dụng đúng component SideRail và Header, đồng nhất với thiết kế của Bước 1.

## Scenarios

### Scenario 1: Sửa lỗi phân loại bằng Drag & Drop
**Given** AI phân loại nhầm một NST số 2 vào ô số 3 trên lưới.
**When** Chuyên viên nắm kéo (drag) NST từ ô số 3 và thả (drop) sang ô số 2.
**Then** NST xuất hiện ở ô số 2, biến mất ở ô số 3, và hệ thống chỉ cập nhật Local State (không gọi API tải lại trang).

### Scenario 2: Tách cụm NST bị dính
**Given** Có một cụm gồm 2 NST dính nhau nằm ở Unclassified Pool.
**When** Chuyên viên chọn công cụ Lasso và vẽ đường bao quanh một nhánh NST.
**Then** Phần được vẽ bao quanh sẽ tách ra thành một NST riêng biệt có thể kéo thả được, và hình ảnh cụm gốc bị khoét đi phần tương ứng.

### Scenario 3: Lưu trạng thái và chuyển bước
**Given** Chuyên viên đã hoàn thành sửa đổi và sắp xếp toàn bộ Karyotype.
**When** Chuyên viên bấm nút "Hoàn thành".
**Then** Hệ thống gửi toàn bộ mảng tọa độ/phân loại hiện tại lên Firestore, cập nhật trạng thái làm việc, và điều hướng sang màn hình Bước 3.

## Technical Notes

- **State Management**: Sử dụng `Cubit` (ví dụ: `ClassificationCubit`) để quản lý danh sách NST hiện tại. Khi `DragEnd`, gọi method `moveChromosome(id, newTarget)` trong Cubit để `emit` state mới.
- **Lasso Tool Implementation**: Có thể cân nhắc sử dụng `CustomPaint` và `GestureDetector` (để bắt sự kiện Pan/mô phỏng thao tác vẽ) kết hợp với các thuật toán xử lý bitmap masking ở phía frontend, hoặc gửi tọa độ đa giác về microservice backend (FastAPI) nếu xử lý cắt ảnh trên Flutter tốn quá nhiều tài nguyên thiết bị.

## Open Questions

- [ ] Thao tác cắt tách hình ảnh (Lasso) sẽ được xử lý hoàn toàn ở frontend (Flutter Image manipulation) hay frontend chỉ gửi tọa độ về backend để backend xử lý crop và trả về URL của 2 ảnh con?
