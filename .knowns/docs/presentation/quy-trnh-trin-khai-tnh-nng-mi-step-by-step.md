---
title: Quy trình triển khai tính năng mới (Step-by-Step)
description: Hướng dẫn từng bước cách triển khai một tính năng mới trong dự án theo mô hình Clean Architecture (Bắt đầu từ đâu, tạo file nào trước).
createdAt: '2026-05-14T07:16:53.562Z'
updatedAt: '2026-05-14T07:55:24.274Z'
tags:
  - architecture
  - workflow
  - clean-architecture
  - guide
---

# Quy trình triển khai tính năng mới (Step-by-Step)

## Nguyên tắc cốt lõi: Inside-Out (Từ Trong ra Ngoài)
Trong kiến trúc **Clean Architecture**, quy trình chuẩn nhất và an toàn nhất là **Đi từ Trong ra Ngoài** (Inside-Out). Nghĩa là chúng ta bắt đầu từ lớp **Domain** (Lõi nghiệp vụ) ➡️ **Data** (Dữ liệu) ➡️ **Logic** (Quản lý trạng thái) ➡️ **Presentation** (Giao diện).

Quy trình này giúp bạn không bị phụ thuộc vào giao diện hay cơ sở dữ liệu (Firestore) ngay từ đầu, giúp code dễ kiểm thử (Testable) và dễ bảo trì hơn.

---

## Các bước triển khai chi tiết

### 🟢 Bước 1: Khởi tạo lớp Domain (Lõi nghiệp vụ)
Đừng vội đụng vào UI hay Firestore. Hãy xác định xem tính năng này cần xử lý dữ liệu gì và có các hành động nào.

1. **Tạo Entity**:
   - Vị trí: `lib/domain/entities/`
   - Nhiệm vụ: Tạo một class Dart thuần (không phụ thuộc thư viện ngoài) định nghĩa các trường dữ liệu cốt lõi.
   - *Ví dụ*: `Appointment` có `id`, `date`, `userId`, `status`.
2. **Tạo Abstract Repository (Interface)**:
   - Vị trí: `lib/domain/repositories/`
   - Nhiệm vụ: Tạo một class trừu tượng định nghĩa các hàm (hành động) cần dùng.
   - *Ví dụ*: `abstract class AppointmentRepository` có hàm `Future<List<Appointment>> getTodayAppointments();`.

---

### 🟡 Bước 2: Khởi tạo lớp Data (Giao tiếp dữ liệu)
Sau khi đã có "hợp đồng" ở lớp Domain, chúng ta đi hiện thực hóa nó.

1. **Tạo Model**:
   - Vị trí: `lib/data/models/`
   - Nhiệm vụ: Tạo class kế thừa từ Entity ở Bước 1. Bổ sung các hàm `fromFirestore` (hoặc `fromMap`) và `toFirestore` (hoặc `toMap`) để chuyển đổi dữ liệu từ Firestore.
   - **💡 Quy tắc: Tạo Model trước hay DataSource trước?** ➡️ **Tạo Model trước**. Vì DataSource cần biết kiểu dữ liệu trả về là gì để map dữ liệu thô từ Firestore vào.
2. **Tạo DataSource**:
   - Vị trí: `lib/data/datasources/`
   - Nhiệm vụ: Viết code gọi trực tiếp Firebase Firestore. Trả về Model vừa tạo ở trên.
   - *Ví dụ*: `AppointmentRemoteDataSource` gọi `_firestore.collection('appointments').get()`.
3. **Tạo Repository Implementation**:
   - Vị trí: `lib/data/repositories/`
   - Nhiệm vụ: Class này sẽ `implements` cái Abstract Repository ở Bước 1. Nó sẽ gọi đến DataSource để lấy dữ liệu và trả về cho lớp Domain.
   - Đừng quên gắn `@LazySingleton(as: AppointmentRepository)` lên đầu class để GetIt tự động đăng ký.

---

### 🔵 Bước 3: Khởi tạo lớp Logic (Quản lý trạng thái)
Bây giờ dữ liệu đã sẵn sàng, chúng ta cần đưa nó lên một "vùng chứa" (State) để UI có thể lắng nghe.

1. **Tạo State**:
   - Vị trí: `lib/logic/bloc/feature_name/`
   - Tạo file `feature_state.dart`. Định nghĩa các trạng thái: `Initial`, `Loading`, `Loaded` (chứa list dữ liệu), `Error`.
2. **Tạo Cubit**:
   - Vị trí: `lib/logic/bloc/feature_name/`
   - Tạo file `feature_cubit.dart`. Inject Repository vào qua constructor.
   - Viết hàm gọi Repository, bắt lỗi `try-catch` và `emit` các trạng thái tương ứng.

---

### 🔴 Bước 4: Khởi tạo lớp Presentation (Giao diện)
Bước cuối cùng, vẽ giao diện và gắn logic vào.

1. **Tạo Screen/Widget**:
   - Vị trí: `lib/presentation/screens/` hoặc `widgets/`.
2. **Sử dụng BlocBuilder/BlocListener**:
   - Bọc giao diện bằng `BlocBuilder<FeatureCubit, FeatureState>`.
   - Dựa vào state để hiển thị: `Loading` ➡️ Show vòng quay; `Loaded` ➡️ Show list dữ liệu; `Error` ➡️ Show text lỗi.

---

## 💡 Tại sao phải đi qua nhiều tầng như vậy?

Nhiều bạn sẽ thắc mắc: *"Tại sao không gọi thẳng Firestore từ UI cho nhanh? Viết chi qua tới 4-5 file cho mệt vậy?"*

Lý do là để **Tách biệt trách nhiệm (Separation of Concerns)**. Mỗi tầng chỉ làm đúng một việc:
1. **UI**: Chỉ lo hiển thị. Không quan tâm dữ liệu lấy từ đâu.
2. **Cubit**: Chỉ lo quản lý trạng thái. Không quan tâm Firestore query như thế nào.
3. **Repository**: Là người điều phối.
4. **DataSource**: Chỉ lo việc kết nối với Database và trả về dữ liệu thô.

### 🚀 Trường hợp đổi qua Supabase thì sao? Có phải sửa nhiều không?

Đây chính là lúc **Clean Architecture** tỏa sáng!

Nếu dự án quyết định chuyển từ **Firebase Firestore** sang **Supabase**:
- **Bạn KHÔNG cần sửa**: UI (Screens), Cubit, State, Entity, và Abstract Repository. Tất cả những thứ này giữ nguyên 100%!
- **Bạn CHỈ CẦN sửa ở lớp Data** (Cụ thể là file trong folder `datasources` và `models`).

**💡 Ví dụ cụ thể về việc sửa đổi trong `datasources`:**

Giả sử chúng ta có hàm lấy danh sách cuộc hẹn trong ngày.

**1. Code hiện tại dùng Firebase (`lib/data/datasources/appointment_remote_datasource.dart`):**
```dart
class FirebaseAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  @override
  Future<List<AppointmentModel>> getTodayAppointments() async {
    final snapshot = await _firestore.collection('appointments').get();
    // Firebase trả về QuerySnapshot, ta map từng Document thành Model
    return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
  }
}
```

**2. Code mới khi chuyển sang Supabase (`lib/data/datasources/supabase_appointment_datasource.dart`):**
```dart
class SupabaseAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  final SupabaseClient _supabase;
  
  @override
  Future<List<AppointmentModel>> getTodayAppointments() async {
    final response = await _supabase.from('appointments').select();
    // Supabase trả về List<Map>, ta map trực tiếp thành Model
    return response.map((data) => AppointmentModel.fromSupabase(data)).toList();
  }
}
```

**💡 Lưu ý về kiểu dữ liệu:**
Như đã nói ở trên, trong `AppointmentModel`, bạn sẽ đổi kiểu `DocumentReference` của Firebase thành `String` để phù hợp với Supabase.

---

## 📌 Tóm tắt thứ tự tạo file:
`Entity` ➡️ `Abstract Repository` ➡️ `Model` ➡️ `DataSource` ➡️ `Repository Impl` ➡️ `State` ➡️ `Cubit` ➡️ `Screen/Widget`.

---
Tài liệu này bổ sung cho bộ tài liệu kiến trúc trong @doc/presentation/cu-trc-th-mc-lib-v-kin-trc-ng-dng.
