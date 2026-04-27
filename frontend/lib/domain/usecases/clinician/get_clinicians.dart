import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/clinician_repository.dart';

class GetClinicians {
  final ClinicianRepository repository;

  GetClinicians(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return repository.getClinicians();
  }
}
