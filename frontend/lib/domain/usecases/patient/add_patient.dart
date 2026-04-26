import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/patient.dart';
import '../../repositories/patient_repository.dart';

@injectable
class AddPatient {
  final PatientRepository repository;

  AddPatient(this.repository);

  Future<Either<Failure, void>> call(Patient patient) async {
    // Ở đây bạn có thể thêm Logic nghiệp vụ trước khi lưu
    // Ví dụ: Kiểm tra xem bệnh nhân có đủ tuổi không, có thiếu thông tin gì không...

    return await repository.addPatient(patient);
  }
}
