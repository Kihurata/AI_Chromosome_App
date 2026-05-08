import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/sample.dart';
import '../../repositories/sample_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class CollectPhysicalSample {
  final SampleRepository repository;

  CollectPhysicalSample(this.repository);

  Future<Either<Failure, void>> call(Sample sample) {
    return repository.createSample(sample);
  }
}
