---
title: Dependency Injection (DI) trong dự án
description: Tài liệu chi tiết về cách sử dụng GetIt và Injectable để quản lý phụ thuộc (Dependency Injection) trong dự án.
createdAt: '2026-05-14T08:02:31.602Z'
updatedAt: '2026-05-14T08:18:26.977Z'
tags:
  - architecture
  - di
  - get-it
  - injectable
---

# Dependency Injection (DI) trong dự án

## 1. Khái niệm cơ bản
**Dependency Injection (DI)** (Tiêm phụ thuộc) là một kỹ thuật thiết kế phần mềm giúp tách biệt việc **khởi tạo** một đối tượng khỏi việc **sử dụng** nó. Thay vì một class tự khởi tạo các class con mà nó cần (Dependency) bằng từ khóa `new`, các class con đó sẽ được "tiêm" (truyền) từ bên ngoài vào qua Constructor.

## 2. Tại sao dự án sử dụng DI?
- **Giảm sự phụ thuộc chặt chẽ (Loose Coupling)**: Các class không cần biết làm thế nào để tạo ra các dependency của nó.
- **Dễ dàng viết Unit Test**: Chúng ta có thể dễ dàng truyền các bản Mock (giả lập) của Repository hay DataSource vào Cubit khi viết test mà không cần đụng vào code thực tế.
- **Quản lý vòng đời đối tượng**: Dễ dàng cấu hình một class là Singleton (chỉ tạo 1 lần duy nhất) hay Factory (tạo mới mỗi lần gọi).

## 3. Thư viện sử dụng
Dự án sử dụng bộ đôi phổ biến nhất trong hệ sinh thái Flutter:
- **`get_it`**: Một Service Locator đơn giản giúp lưu trữ và truy xuất các instance của các class từ bất kỳ đâu trong app.
- **`injectable`**: Một thư viện tự động tạo code (Code Generator). Nó quét các Annotation trong dự án và tự động sinh ra code đăng ký vào `get_it`, giúp lập trình viên không phải viết code đăng ký thủ công dài dòng.

## 4. Chi tiết về Quản lý vòng đời đối tượng (Lifecycle)

Trong dự án, việc quản lý vòng đời đối tượng rất quan trọng để tối ưu bộ nhớ và đảm bảo tính nhất quán của dữ liệu. Thư viện `injectable` cung cấp các Annotation sau để định nghĩa điều này:

### 🟢 1. `@LazySingleton` (Khuyên dùng cho Repository & DataSource)
- **Khái niệm**: Đây là một **Singleton** (chỉ tạo duy nhất một instance trong suốt vòng đời của app), nhưng nó mang tính chất **Lazy** (lười biếng).
- **Cơ chế hoạt động**: Instance của class sẽ **KHÔNG** được tạo ra ngay khi app vừa khởi chạy. Nó chỉ được tạo ra vào đúng thời điểm có một class khác yêu cầu gọi nó lần đầu tiên. Từ lần gọi thứ 2 trở đi, nó sẽ trả về đúng instance đã tạo trước đó.
- **Lý do sử dụng**: Tiết kiệm bộ nhớ RAM lúc khởi động app. Rất thích hợp cho các class nặng nề hoặc không phải lúc nào cũng cần dùng ngay.
- **Ví dụ thực tế**:
   ```dart
   @LazySingleton(as: AppointmentRepository)
   class FirebaseAppointmentRepository implements AppointmentRepository {
     // ...
   }
   ```

### 🟡 2. `@singleton` (Ít dùng hơn)
- **Khái niệm**: Cũng tạo ra một instance duy nhất.
- **Cơ chế hoạt động**: Khác với Lazy, nó sẽ được khởi tạo **NGAY LẬP TỨC** khi hàm `configureDependencies()` được gọi trong `main.dart`.
- **Lý do sử dụng**: Dùng cho các service cần sẵn sàng ngay lập tức (ví dụ: Service lắng nghe trạng thái mạng, Service cấu hình Firebase).

### 🔵 3. `@injectable` (Factory - Khuyên dùng cho Cubit)
- **Khái niệm**: Đây là kiểu **Factory**.
- **Cơ chế hoạt động**: Mỗi lần bạn gọi `getIt<MyCubit>()`, nó sẽ **TẠO MỚI HOÀN TOÀN** một instance khác nhau.
- **Lý do sử dụng**: Cực kỳ phù hợp cho các Cubit/Bloc gắn liền với một màn hình cụ thể. Khi người dùng thoát màn hình đó và vào lại, chúng ta muốn một Cubit mới với trạng thái ban đầu sạch sẽ, không bị lưu lại rác từ phiên làm việc trước.

---

## 5. 💡 Tại sao Cubit phải dùng `@injectable` (Kiểu Factory)?

Cubit là nơi giữ trạng thái (State) của giao diện. Việc dùng `@injectable` (hoặc khởi tạo thủ công kiểu Factory) cho Cubit là **bắt buộc** vì các lý do sau:

1. **Tránh rò rỉ trạng thái (State Leak)**: Nếu Cubit là Singleton, khi bạn thoát màn hình A và vào lại, trạng thái cũ (ví dụ: dữ liệu cũ, thông báo lỗi cũ) vẫn còn đó. Dùng Factory đảm bảo mỗi lần vào màn hình, bạn nhận được một Cubit mới toanh.
2. **Tự động giải phóng (Dispose)**: Flutter's `BlocProvider` sẽ tự động `close()` Cubit khi Widget bị remove khỏi cây. Nếu là Singleton, việc close này sẽ làm hỏng Cubit cho các lần dùng sau.

### 🔍 Ví dụ thực tế: `WorkspaceCubit`

Hãy nhìn vào file `lib/logic/bloc/workspace/workspace_cubit.dart` trong dự án của bạn:

```dart
class WorkspaceCubit extends Cubit<WorkspaceState> {
  final UpdateChromosomePosition updatePositionUsecase;
  final SubmitAnalysisResult submitAnalysisUsecase;
  final WorkspaceRepository workspaceRepository;
  final String orderId; // ➡️ ĐÂY LÀ RUNTIME PARAMETER

  WorkspaceCubit({
    required this.updatePositionUsecase,
    // ...
    required this.orderId,
  }) : super(WorkspaceState(chromosomes: []));
}
```

**Phân tích Case này**:
- `WorkspaceCubit` cần các Usecase và Repository (có thể lấy từ GetIt).
- Nhưng nó lại cần `orderId` (dữ liệu động, mỗi ca khám có một ID khác nhau), chỉ biết được khi người dùng mở màn hình.
- **Cách xử lý**: Vì có `orderId` động, chúng ta khởi tạo thủ công trong `BlocProvider` ở UI, nhưng vẫn tận dụng GetIt để lấy các phụ thuộc khác:
```dart
BlocProvider(
  create: (context) => WorkspaceCubit(
    updatePositionUsecase: getIt<UpdateChromosomePosition>(),
    submitAnalysisResult: getIt<SubmitAnalysisResult>(),
    workspaceRepository: getIt<WorkspaceRepository>(),
    orderId: currentOrderId, // ➡️ Truyền ID động từ UI vào
  ),
)
```
- **Ý nghĩa**: Đây vẫn là mô hình Factory (tạo mới mỗi lần vào màn hình) nhưng có kết hợp tham số động!

---

## 6. Khởi tạo trong `main.dart`
Trước khi app chạy, trong file `main.dart` sẽ gọi hàm cấu hình:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  configureDependencies(); // ➡️ Gọi hàm này để khởi tạo DI
  runApp(const ProviderScope(child: MyApp()));
}
```

---
Tài liệu này bổ sung cho mục `di/` trong @doc/presentation/chi-tit-lp-core-libcore.
