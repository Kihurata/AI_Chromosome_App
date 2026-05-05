import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../repositories/sample_repository.dart';

@lazySingleton
class UpdateSampleNoteUsecase {
  final SampleRepository repository;

  UpdateSampleNoteUsecase(this.repository);

  Future<Either<Failure, void>> call(String id, String note) {
    return repository.updateSampleNote(id, note);
  }
}
