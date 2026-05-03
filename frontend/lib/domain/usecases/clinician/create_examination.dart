import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/examination.dart';
import '../../repositories/examination_repository.dart';

class CreateExamination {
  final ExaminationRepository repository;

  CreateExamination(this.repository);

  Future<Either<Failure, void>> call(Examination examination) {
    return repository.createExamination(examination);
  }
}
