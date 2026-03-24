# Luồng Dữ Liệu & Trạng Thái (Data Flow)

## 1. Toàn cảnh luồng dữ liệu (Data Flow Overview)
Luồng dữ liệu của hệ thống Chromosome Karyotyping được thiết kế đi tuyến tính từ ngoài vào trong, phản ánh chính xác quy trình y tế thực tế:
**Lâm sàng (Khám) ➔ Cận lâm sàng (Lấy mẫu) ➔ Phòng Lab (Nuôi cấy) ➔ Máy chủ AI (Phân tích) ➔ Bác sĩ Di truyền (Kết luận & Báo cáo).**

Mọi sự thay đổi trạng thái (Status) ở các Node cấp thấp (VD: `samples`) sẽ kích hoạt Firebase Cloud Functions để tự động cập nhật trạng thái ở Node cấp cao (`test_orders`), giảm thiểu thao tác thủ công cho nhân viên.

---

## 2. Chi tiết từng giai đoạn và Status (State Machine)

### Giai đoạn 1: Đặt lịch & Thăm khám (Clinical Stage)
*   **Hành động:** Bệnh nhân đặt lịch. Bác sĩ lâm sàng khám và chỉ định làm xét nghiệm di truyền (karyotyping).
*   **Data Logic:**
    *   Tạo `appointment` mới.
    *   Khi khám xong, Bác sĩ tạo `test_orders`.
*   **Status Phối hợp (Sync):**
    *   `appointments.status`: `scheduled` ➔ `checked-in` ➔ `completed`
    *   `test_orders.status`: Khởi tạo là `PENDING`

### Giai đoạn 2: Tiếp nhận mẫu & Tạo mã QR (Sample Collection)
*   **Hành động:** Y tá/Kỹ thuật viên lấy mẫu bệnh phẩm (máu ngoại vi, dịch ối, v.v.) và dán mã QR định danh lên ống nghiệm.
*   **Data Logic:**
    *   Tạo document mới trong collection `samples`, liên kết (reference) tới `test_orders` thông qua `current_sample_id`.
    *   Ghi nhận `collection_time` (Thời điểm lấy mẫu).
*   **Status Phối hợp (Sync):**
    *   `samples.status`: `COLLECTED`
    *   `test_orders.status`: Vẫn giữ nguyên `PENDING`

### Giai đoạn 3: Nuôi cấy tế bào (Lab Culturing)
*   **Hành động:** Kỹ thuật viên quét mã QR trên ống nghiệm và đưa vào tủ ấm nuôi cấy.
*   **Data Logic:**
    *   Ghi nhận `culture_start_time`.
    *   Backend tự động tính toán `expected_culture_days` dựa vào `sample_type`.
*   **Status Phối hợp (Sync):**
    *   `samples.status`: Chuyển sang `CULTURING`
    *   `test_orders.status`: **Tự động** chuyển sang `CULTURING` (Thông qua Firestore Cloud Functions trigger `onUpdate` của collection `samples`).

### Giai đoạn 4: Thu hoạch & Chụp ảnh (Harvesting & Imaging)
*   **Hành động:** Đủ ngày nuôi cấy, KTV lấy mẫu làm tiêu bản, soi kính hiển vi và tải 20-50 ảnh Metaphase lên màn hình Lightbox của hệ thống.
*   **Data Logic:**
    *   Tạo các documents trong sub-collection `test_orders/{orderId}/metaphase_images`.
    *   Hệ thống gọi Local AI Server đếm sơ bộ số lượng NST và cập nhật `ai_count`.
*   **Status Phối hợp (Sync):**
    *   `samples.status`: Chuyển sang `HARVESTED`
    *   `test_orders.status`: Tự động chuyển qua `ANALYZING`

### Giai đoạn 5: Phân tích AI & Hiệu chỉnh (AI Analysis & Human Review)
*   **Hành động:** Bác sĩ Di truyền (Specialist) chọn ảnh đẹp nhất. AI tiến hành Segmentation và Classification. Bác sĩ dùng workspace kéo-thả để hiệu chỉnh sai sót của AI.
*   **Data Logic:**
    *   Ghi đè `chromosomes` coordinates và labels.
    *   Ghi nhận toàn bộ thao tác vào `audit_logs` (Bắt buộc về pháp lý).
*   **Status Phối hợp (Sync):**
    *   `samples.status`: Giữ nguyên `HARVESTED` (Quy trình vật lý đã hoàn tất)
    *   `test_orders.status`: Vẫn là `ANALYZING`

### Giai đoạn 6: Kết luận & Phê duyệt (Reporting)
*   **Hành động:** Bác sĩ Specialist điền công thức chuẩn quốc tế ISCN, ghi note kết luận chẩn đoán, ký số (duyệt), và hệ thống xuất PDF.
*   **Data Logic:**
    *   Cập nhật trường `iscn_formula` (vd: `47,XX,+21`), `diagnosis_conclusion`, và `final_report_url` vào `test_orders`.
*   **Status Phối hợp (Sync):**
    *   `test_orders.status`: Chuyển sang `COMPLETED`
    *   `samples.status`: Giữ nguyên `HARVESTED` (Mẫu vật lý được lưu trữ/hủy theo quy định y tế bên ngoài hệ thống số).

---

## 3. Trường hợp ngoại lệ: Mẫu hỏng (The "Failed" Path)

Trong quy trình xét nghiệm di truyền, rủi ro tế bào không phát triển (nuôi cấy thất bại) là có thể xảy ra. Hệ thống xử lý rẽ nhánh luồng dữ liệu như sau:

1.  **Kích hoạt:** Bác sĩ di truyền / KTV Lab đổi `samples.status` = `FAILED` và ghi chú vào trường `note`.
2.  **Tự động hóa:** Cloud Function kích hoạt, đổi `test_orders.status` = `FAILED`.
3.  **Thông báo:** Trigger Notification thông báo tức thời cho Bác sĩ Lâm sàng: *"Mẫu của bệnh nhân XYZ đã hỏng, cần lấy lại mẫu mới."*
4.  **Tái khởi động quy trình:**
    *   Khách hàng được hẹn lấy lại mẫu.
    *   Một **`samples` document mới** được tạo ra (Mã QR mới).
    *   Firestore cập nhật trường `current_sample_id` của `test_orders` hiện tại trỏ sang QR mới này.
    *   `test_orders.status` quay trở lại `PENDING` và lặp lại Giai đoạn 2.

> **Góc nhìn UX Y Khoa:** Việc tách bạch cực kỳ chi tiết tracking trạng thái giữa `samples` (vật lý) và `test_orders` (quy trình) giúp Bác sĩ lâm sàng nắm được ngay nút thắt (bottleneck). Nếu status kẹt ở `CULTURING` > 15 ngày, Bác sĩ hiểu là quá trình nuôi cấy phòng Lab đang có biến cố mà không cần tốn thời gian gọi điện nội bộ.

---

## 4. Đối chiếu tính nhất quán (Consistency with ARCHITECTURE.md)

Sau khi đối chiếu chi tiết Data Flow với Schema đã định nghĩa trong `docs/ARCHITECTURE.md`, dữ liệu được cam kết đồng nhất 100%:

1.  **Status Enums Đồng Bộ Tuyệt Đối:**
    *   `samples.status`: Chỉ sử dụng đúng 4 trạng thái vật lý cho phép `[COLLECTED, CULTURING, HARVESTED, FAILED]`. Sau Giai đoạn 4 (Harvested), mẫu vật lý khóa trạng thái, nhường chỗ hoàn toàn cho quy trình phân tích số.
    *   `test_orders.status`: Trải qua đủ cấu trúc tiến độ `[PENDING, CULTURING, ANALYZING, COMPLETED, FAILED]`.
2.  **Khớp Nối Khoá Ngoại (References):**
    *   Mỗi khi tạo mã QR ở *Giai đoạn 2*, `current_sample_id` bên trong `test_orders` được trỏ chính xác vào Document ID của mẫu mới nhất.
    *   Logic tự động cập nhật status được ủy quyền hoàn toàn qua Firebase Cloud Functions thay vì gánh nặng từ Client, tuân thủ đúng định hướng Event-driven của NoSQL.
