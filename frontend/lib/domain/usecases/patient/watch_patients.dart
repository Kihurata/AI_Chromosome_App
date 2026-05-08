import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/patient.dart';
import '../../repositories/patient_repository.dart';

@injectable
class WatchPatients {
  final PatientRepository repository;

  WatchPatients(this.repository);

  Stream<Either<Failure, List<Patient>>> call() {
    return repository.watchPatients();
  }
}
