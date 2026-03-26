# AI Chromosome Karyotyping App (Monorepo)

Hệ thống quản lý phòng khám (CRM) và phân tích nhiễm sắc thể (Karyotyping) chuyên dụng. Dự án được chia làm 2 phần chính: Frontend (Flutter) và Backend (FastAPI).

## 📁 Cấu trúc thư mục (Monorepo)
-   **/frontend**: Ứng dụng Flutter cho Bác sĩ và Nhân viên (Web & Desktop).
-   **/backend**: API máy chủ xây dựng bằng Python FastAPI (Xử lý AI, Firebase Admin SDK).
-   **/docs**: Tài liệu kiến trúc, luồng dữ liệu và các quyết định công nghệ.

---

## 🚀 Hướng dẫn khởi chạy

### 1. Frontend (Flutter)
Đảm bảo bạn đã cài đặt Flutter SDK và Firebase CLI.

```bash
cd frontend
flutter pub get

# Chạy ứng dụng (Chrome/Windows/MacOS)
flutter run -d chrome
```

### 2. Backend (FastAPI)
Yêu cầu Python 3.9+ và cài đặt các thư viện cần thiết.

```bash
cd backend
pip install -r requirements.txt

# Chạy server development
uvicorn main:app --reload
```

---

## 🛠 Kiến trúc & Công nghệ (Tech Stack)

### Frontend
-   **Framework**: Flutter 3.x
-   **Quản lý trạng thái (Hybrid)**: 
    -   **Riverpod**: Dùng làm "Data Pipe" để stream dữ liệu realtime từ Firestore.
    -   **Cubit (Bloc)**: Dùng làm "UI Controller" quản lý tương tác kéo-thả trong workspace.
-   **Tài liệu chi tiết**: Xem tại [docs/ADR-state-management.md](docs/ADR-state-management.md)

### Backend
-   **Framework**: FastAPI (Python)
-   **Firebase Admin SDK**: Quản lý dữ liệu tập trung và Proxy tới AI Server.
-   **AI Integration**: Tích hợp các mô hình Segmentation/Classification (OpenCV, PyTorch/TensorFlow).

---

## 📝 Quy trình phát triển (Data Flow)
Mọi trạng thái xét nghiệm đi qua 6 giai đoạn từ lúc đặt lịch đến khi có báo cáo PDF.
Chi tiết xem tại: [docs/DATAFLOW.md](docs/DATAFLOW.md)

---

## 🔒 Firebase Configuration
Dự án sử dụng Firebase cho Authentication, Firestore và Storage.
-   File cấu hình Flutter: `frontend/lib/core/firebase/firebase_options.dart`.
-   File cấu hình Backend: `backend/serviceAccountKey.json` (Không commit lên Git).

---

## 🛠 Cài đặt môi trường mới (Setup for new machine)

Để chạy dự án sau khi clone về máy tính mới, bạn cần thực hiện các bước sau:

### 1. File cấu hình (Secrets)
Do không được commit lên Git vì lý do bảo mật, bạn cần chuẩn bị:
-   **Backend**: Copy file `serviceAccountKey.json` vào thư mục `/backend`. Bạn có thể dùng `backend/serviceAccountKey.example.json` làm mẫu hoặc tải file mới từ Firebase Console (Project Settings > Service accounts).

### 2. Firebase CLI
Đảm bảo bạn đã cài đặt Firebase CLI và đăng nhập:
```bash
npm install -g firebase-tools
firebase login
```

### 3. Flutter Setup
```bash
cd frontend
flutter pub get
# Nếu cần cấu hình lại Firebase cho Flutter:
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4. Python Backend Setup
Dự án yêu cầu cài đặt thư viện cần thiết cho Backend:
```bash
cd backend
pip install -r requirements.txt
# Nếu chưa có requirements.txt, hãy cài đặt base:
pip install firebase-admin fastapi uvicorn
```
