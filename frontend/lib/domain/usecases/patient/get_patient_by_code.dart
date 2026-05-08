import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/patient.dart';
import '../../repositories/patient_repository.dart';

@injectable
class GetPatientByCode {
  final PatientRepository repository;

  GetPatientByCode(this.repository);

  Future<Either<Failure, Patient>> call(String code) async {
    return await repository.getPatientByCode(code);
  }
}
