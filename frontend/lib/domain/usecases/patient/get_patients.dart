import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/patient.dart';
import '../../repositories/patient_repository.dart';

@injectable
class GetPatients {
  final PatientRepository repository;

  GetPatients(this.repository);

  // Chúng ta dùng hàm call() để có thể gọi usecase này như một function: getPatients()
  Future<Either<Failure, List<Patient>>> call() async {
    // Usecase không làm gì cả, nó chỉ đứng ra điều phối và gọi xuống Repository
    return await repository.getPatients();
  }
}
