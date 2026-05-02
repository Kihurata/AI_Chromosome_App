## Overview
Tài liệu này đặc tả logic nghiệp vụ của Backend (FastAPI) đóng vai trò Orchestrator. Nhiệm vụ chính là tiếp nhận yêu cầu phân tích từ Flutter, gọi AI Server (Ngrok), xử lý kết quả JSON (LabelMe format) và lưu trữ vào Firestore để Frontend hiển thị.

## Locked Decisions
- **D9 (Dynamic Config):** URL của AI Server được quản lý tập trung tại Firestore document `system_configs/ai_server`. Cả Flutter và Backend đều đọc từ đây.
- **D10 (Secure Proxy Flow):** Luồng chạy: `Flutter -> FastAPI -> AI Server -> FastAPI -> Firestore`. Giúp ẩn Ngrok URL khỏi client và xử lý bulk-write an toàn.
- **D11 (Data Mapping):** Kết quả từ AI (chuẩn LabelMe) sẽ được map trực tiếp vào collection `test_orders/{id}/metaphase_images/{id}/chromosomes`. Mỗi `shape` trong JSON tương ứng với một document `Chromosome`.

## Requirements

### 1. API Endpoints (FastAPI)
- **FR-1 (Analyze Trigger):** Endpoint `POST /api/analyze` tiếp nhận `orderId` và `imageId`.
  - Đọc `api_url` từ Firestore `system_configs/ai_server`.
  - Lấy `image_url` của ảnh tương ứng từ Firestore.
  - Gọi AI Server qua HTTP POST kèm `image_url`.
- **FR-2 (Result Processing):** Parse kết quả JSON trả về.
  - Tính toán Bounding Box (x, y, w, h) từ tập hợp `points` của mỗi NST.
  - Khởi tạo trạng thái ban đầu cho mỗi NST: `status: 'unclassified'`, `is_manual: false`.
- **FR-3 (Data Persistence):** Sử dụng Firebase Admin SDK để thực hiện `BulkWrite` (hoặc `write_batch`) nhằm lưu toàn bộ NST vào Firestore trong một giao dịch duy nhất để đảm bảo tính toàn vẹn.

### 2. State Transitions
- **ST-1 (Image Status):** 
  - Khi bắt đầu gọi AI: `metaphase_images.status = 'PROCESSING'`.
  - Khi lưu xong dữ liệu: `metaphase_images.status = 'COMPLETED'`.
  - Nếu AI Server lỗi hoặc timeout: `metaphase_images.status = 'FAILED'`.

## Acceptance Criteria
- [ ] **AC-1:** Backend đọc đúng URL từ Firestore `system_configs/ai_server`. Nếu không thấy URL, trả về lỗi 500 kèm thông báo cấu hình.
- [ ] **AC-2:** Gửi đúng payload `{"image_url": "..."}` tới AI Server.
- [ ] **AC-3:** Toàn bộ các NST trong file JSON (ví dụ 46 NST) phải được tạo thành 46 documents tương ứng trong sub-collection `chromosomes`.
- [ ] **AC-4:** Mỗi `Chromosome` document phải chứa mảng `points` (tọa độ gốc) và `label` (số cặp NST dự đoán).
- [ ] **AC-5:** Thời gian timeout cho mỗi yêu cầu AI tối thiểu là 60 giây (do AI xử lý nặng).

## Technical Notes
- **Ngrok Header:** Khi gọi AI Server qua Ngrok, cần thêm header `"ngrok-skip-browser-warning": "true"` để tránh trang cảnh báo của Ngrok làm hỏng request.
- **Concurrency:** Sử dụng `asyncio` và `httpx` trong FastAPI để không block server trong khi chờ AI xử lý.
- **Batch Write Limit:** Firestore giới hạn 500 thao tác mỗi batch, nhưng 1 ca thường chỉ có ~46 NST nên hoàn toàn nằm trong giới hạn.
