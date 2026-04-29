import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/sample.dart';
import '../../repositories/lab_processing_repository.dart';

class UpdateSampleLabStatus {
  final LabProcessingRepository repository;

  UpdateSampleLabStatus(this.repository);

  Future<Either<Failure, void>> call(String sampleId, SampleStatus status) {
    return repository.updateSampleLabStatus(sampleId, status);
  }
}
