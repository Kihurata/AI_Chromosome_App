import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/patient.dart';
import '../../repositories/patient_repository.dart';

@injectable
class CheckDuplicatePatient {
  final PatientRepository repository;

  CheckDuplicatePatient(this.repository);

  Future<Either<Failure, Patient?>> call({String? identityCard, String? phone}) async {
    return await repository.checkDuplicatePatient(identityCard: identityCard, phone: phone);
  }
}
