import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/patient.dart';
import '../../repositories/patient_repository.dart';

@injectable
class GetPatientById {
  final PatientRepository repository;

  GetPatientById(this.repository);

  Future<Either<Failure, Patient>> call(String id) async {
    return await repository.getPatientById(id);
  }
}
