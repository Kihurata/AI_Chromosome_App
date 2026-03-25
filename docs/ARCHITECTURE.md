# System Architecture & Database Schema

## 1. Overview
The Chromosome Karyotyping App uses **Firebase Firestore** (NoSQL) for real-time synchronization and data storage, driven by a **FastAPI** backend proxy and **Flutter** frontend. The schema maps traditional relational concepts to Firestore Collections and Documents.

## 2. Core Collections (Database Schema)

### 👤 Authentication & Role Management

#### Collection: `users`
*(Lưu trữ thông tin cơ bản và phân quyền cho mọi nhân viên trong bệnh viện)*
| Field | Type | Note |
|-------|------|------|
| `uid` | `String` (Doc ID) | Lấy từ Firebase Auth |
| `email` | `String` | |
| `full_name` | `String` | |
| `role` | `Enum` | `admin`, `clinician`, `specialist`, `receptionist` |
| `created_at` | `Timestamp` | |
| `status` | `String` | `active`, `inactive` |

#### Collection: `doctors`
*(Chi tiết chuyên môn. Chỉ tồn tại nếu role là `clinician` hoặc `specialist`)*
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Trùng với `uid` của bảng `users` |
| `specialty` | `String` | Chuyên khoa (vd: Sản, Di truyền, Huyết học) |
| `department_id`| `String` | |

---

### 👥 Patient Management & Scheduling

#### Collection: `patients`
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Primary Key |
| `patient_code`| `String` | Mã y tế |
| `full_name` | `String` | |
| `dob` | `Date` | Ngày sinh |
| `gender` | `String` | |
| `contact` | `String` | Số điện thoại |

#### Collection: `appointments`
*(Lịch hẹn khám)*
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Primary Key |
| `patient_id` | `Reference` | Liên kết đến `patients` |
| `patient_name`| `String` | (Denormalized) Tên bệnh nhân |
| `doctor_id` | `Reference` | Bác sĩ khám lâm sàng (Liên kết đến `doctors`) |
| `doctor_name` | `String` | (Denormalized) Tên bác sĩ |
| `appointment_date`| `Timestamp` | |
| `status` | `Enum` | `scheduled`, `checked-in`, `completed`, `cancelled` |
| `reason` | `Text` | Lý do khám |

---

### 🧪 Laboratory & Diagnostics

#### Collection: `test_orders` (Phiếu xét nghiệm NST)
*(Cầu nối giữa khám lâm sàng và phân tích phòng Lab)*
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Primary Key |
| `patient_id` | `Reference` | Liên kết đến bệnh nhân gốc (`patients`) |
| `patient_name`| `String` | (Denormalized) Tên bệnh nhân |
| `patient_code`| `String` | (Denormalized) Mã y tế |
| `appointment_id`| `Reference` | Liên kết đến lịch hẹn khám gốc (`appointments`) |
| `current_sample_id`| `Reference` | Liên kết với mẫu vật lý hiện tại (`samples`) |
| `specialist_id`| `Reference` | Bác sĩ di truyền phụ trách xử lý AI (`doctors`) |
| `status` | `Enum` | `PENDING`, `CULTURING`, `ANALYZING`, `COMPLETED`, `FAILED` |
| `iscn_formula`| `String` | Công thức NST rút gọn (vd: `47,XX,+21`) |
| `diagnosis_conclusion`| `String` | Kết luận chẩn đoán (vd: Hội chứng Down) |
| `final_report_url`| `String` | Đường dẫn file PDF kết quả |
| `created_at` | `Timestamp` | |
| `updated_at` | `Timestamp` | |

#### Collection: `samples` (Mẫu bệnh phẩm)
*(Tracking vật lý mẫu xét nghiệm, định danh trực tiếp qua mã QR)*
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Primary Key (Chính là nội dung mã QR) |
| `test_order_id` | `Reference` | Liên kết với phiếu chỉ định (`test_orders`) |
| `patient_id` | `Reference` | Liên kết đến `patients` (để hiển thị nhanh) |
| `is_current` | `Boolean` | Đánh dấu mẫu đang xử lý chính cho Order |
| `sample_type` | `Enum` | `PERIPHERAL_BLOOD`, `AMNIOTIC_FLUID`, `BONE_MARROW`,... |
| `status` | `Enum` | `COLLECTED`, `CULTURING`, `HARVESTED`, `FAILED` |
| `collection_time` | `Timestamp` | Thời điểm lấy mẫu |
| `culture_start_time` | `Timestamp` | Thời điểm bắt đầu nuôi cấy (nullable) |
| `expected_culture_days`| `Number` | Số ngày dự kiến nuôi (Backend tự tính) |
| `note` | `Text` | Ghi chú tình trạng mẫu |
| `created_at` | `Timestamp` | |
| `updated_at` | `Timestamp` | |

---

### 🧬 Image Data & AI (Sub-collections)
*(Để tối ưu tốc độ truy xuất, các hình ảnh NST lưu theo dạng Sub-collection bên trong mỗi `test_order`)*

#### Collection: `test_orders/{orderId}/metaphase_images`
*(Chứa 20-50 ảnh trong mỗi test order)*
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Primary Key |
| `raw_image_url`| `String` | Ảnh gốc (Firebase Storage) |
| `ai_count` | `Number` | Số lượng NST AI đếm sơ bộ |
| `processing_time` | `Number` | (Denormalized) Thời gian AI xử lý (ms/sec) |
| `is_selected` | `Boolean` | Bác sĩ chọn ảnh này để làm Karyogram |

#### Collection: `test_orders/{orderId}/metaphase_images/{imageId}/chromosomes`
*(Sub-collection chứa dữ liệu NST chi tiết bên trong mỗi ảnh)*
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Doc ID) | Primary Key |
| `label` | `String` | Nhãn AI or Doctor ghi đè |
| `coordinates` | `Map` | Tọa độ `{x, y, w, h}` |
| `mask_url` | `String` | Segmentation mask |
| `rotation` | `Number` | Góc xoay hiện tại (0-360) |
| `is_flipped` | `Boolean` | Trạng thái lật |

---

### 📋 Audit Trail

#### Collection: `audit_logs`
*(High volume: keep as an independent top-level collection)*
| Field | Type | Note |
|-------|------|------|
| `id` | `String` (Auto)| Primary Key |
| `target_id` | `String` | Trỏ đến ID của Order, Image, hoặc Chromosome bị sửa |
| `action_type` | `String` | e.g., `Move`, `Label_Change`, `Rotate` |
| `old_value` | `Map` | Previous state |
| `new_value` | `Map` | New state |
| `timestamp` | `Timestamp` | Exact action time |
| `user_id` | `Reference` | Ai thực hiện hành động |

## 3. Database Design Decisions (`database-architect`)
- **NoSQL Adaptation (Deep Nested Sub-collections):** The most intense read queries occur during the Karyotyping workspace loading. By structuring images as `test_orders/{orderId}/metaphase_images` and then deeply nesting `.../chromosomes`, we isolate data. A doctor fetching an image list won't accidentally fetch thousands of chromosome coordinate objects, heavily reducing Firebase read costs.
- **Role-Based Separation:** Separating `users` (basic auth) from `doctors` (heavy specific logic) allows rapid fetching of basic auth/routing without polluting the context space with massive arrays like `work_schedule` maps.
- **Real-time Sync Constraint:** The highly nested `chromosomes` sub-collection is exactly where active Firestore listeners will latch on for real-time drag-and-drop workspace syncing.
- **Asset Storage:** All `_url` fields (`raw_image_url`, `mask_url`) store URI references to Firebase Cloud Storage buckets, ensuring the document sizes remain well under Firestore's 1MB limit.
- **Denormalization Strategy:** Core fields like `patient_name`, `patient_code`, and `doctor_name` are denormalized across collections to significantly reduce document reads for list views and queues.
- **Sample Lifecycle Management:** The `is_current` flag on `samples` ensures that even if multiple samples exist for a test order (e.g., due to failure), the system always identifies the active one for AI processing.
