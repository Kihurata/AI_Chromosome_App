import 'package:equatable/equatable.dart';
import '../../../domain/entities/patient.dart';

abstract class PatientState extends Equatable {
  const PatientState();
  @override
  List<Object?> get props => [];
}

// 1. Trạng thái ban đầu
class PatientInitial extends PatientState {}

// 2. Đang xử lý (Hiện vòng quay loading)
class PatientLoading extends PatientState {}

// 3. Tải danh sách thành công
class PatientLoaded extends PatientState {
  final List<Patient> patients;
  const PatientLoaded(this.patients);
  @override
  List<Object?> get props => [patients];
}

// 4. Thực hiện hành động (Thêm/Sửa/Xóa) thành công
class PatientActionSuccess extends PatientState {
  final String message;
  const PatientActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// 5. Gặp lỗi
class PatientError extends PatientState {
  final String message;
  const PatientError(this.message);
  @override
  List<Object?> get props => [message];
}

// 6. Xem chi tiết bệnh nhân
class PatientDetailLoaded extends PatientState {
  final Patient patient;
  const PatientDetailLoaded(this.patient);
  @override
  List<Object?> get props => [patient];
}

// 7. Kết quả kiểm tra trùng lặp
class PatientDuplicateChecked extends PatientState {
  final Patient? existingPatient;
  const PatientDuplicateChecked(this.existingPatient);
  @override
  List<Object?> get props => [existingPatient];
}
