import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/sample.dart';
import '../../repositories/sample_repository.dart';

class TransferSampleToLab {
  final SampleRepository repository;

  TransferSampleToLab(this.repository);

  Future<Either<Failure, void>> call(String sampleId) {
    return repository.updateSampleStatus(sampleId, SampleStatus.culturing);
  }
}
