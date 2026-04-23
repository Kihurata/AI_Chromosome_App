import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// --- DƯỚI ĐÂY LÀ CÁC TRƯỜNG HỢP LỖI CỤ THỂ ---
// 1. Lỗi khi gọi AI Server hoặc Firebase bị từ chối/sập
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// 2. Lỗi do bệnh viện/thiết bị bị rớt mạng Internet
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// 3. Lỗi do người dùng nhập sai (Ví dụ: File ảnh sai định dạng)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// 4. Lỗi do không lấy được dữ liệu tạm (ví dụ: lưu tạm ảnh)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
