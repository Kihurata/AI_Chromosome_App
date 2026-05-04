import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/examination.dart';
import '../../repositories/examination_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class CreateExamination {
  final ExaminationRepository repository;

  CreateExamination(this.repository);

  Future<Either<Failure, void>> call(Examination examination) {
    return repository.createExamination(examination);
  }
}
