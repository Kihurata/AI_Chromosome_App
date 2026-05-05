import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../entities/sample.dart';
import '../repositories/sample_repository.dart';

@lazySingleton
class GetSampleByIdUsecase {
  final SampleRepository repository;

  GetSampleByIdUsecase(this.repository);

  Future<Either<Failure, Sample>> call(String id) {
    return repository.getSampleById(id);
  }
}
