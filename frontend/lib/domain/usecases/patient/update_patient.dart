import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/patient.dart';
import '../../repositories/patient_repository.dart';

@injectable
class UpdatePatient {
  final PatientRepository repository;

  UpdatePatient(this.repository);

  Future<Either<Failure, void>> call(Patient patient) async {
    return await repository.updatePatient(patient);
  }
}
