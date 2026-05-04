import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/examination.dart';
import '../../repositories/examination_repository.dart';

@injectable
class GetExaminationsByPatient {
  final ExaminationRepository repository;

  GetExaminationsByPatient(this.repository);

  Future<Either<Failure, List<Examination>>> call(String patientId) async {
    return await repository.getExaminationsByPatientId(patientId);
  }
}
