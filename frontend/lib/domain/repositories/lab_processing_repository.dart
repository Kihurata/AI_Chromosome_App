import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/sample.dart';

abstract class LabProcessingRepository {
  Future<Either<Failure, void>> updateSampleLabStatus(
    String sampleId,
    SampleStatus status,
  );
}
