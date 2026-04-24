import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/patient.dart';

abstract class PatientRepository {
  // Lấy danh sách toàn bộ bệnh nhân
  Future<Either<Failure, List<Patient>>> getPatients();
  // Lấy chi tiết một bệnh nhân qua ID
  Future<Either<Failure, Patient>> getPatientById(String id);
  // Thêm bệnh nhân mới
  Future<Either<Failure, void>> addPatient(Patient patient);
  // Cập nhật thông tin bệnh nhân
  Future<Either<Failure, void>> updatePatient(Patient patient);
  // Xóa bệnh nhân (hoặc đổi trạng thái thành inactive)
  Future<Either<Failure, void>> deletePatient(String id);
}
