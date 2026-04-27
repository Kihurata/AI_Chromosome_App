import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/sample.dart';

abstract class SampleRepository {
  Future<Either<Failure, void>> createSample(Sample sample);
  Future<Either<Failure, void>> updateSampleStatus(
    String sampleId,
    SampleStatus status,
  );
}
