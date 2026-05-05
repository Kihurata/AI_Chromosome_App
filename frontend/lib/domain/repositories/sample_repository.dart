import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/sample.dart';

abstract class SampleRepository {
  Future<Either<Failure, void>> createSample(Sample sample);
  Future<Either<Failure, void>> updateSampleStatus(
    String sampleId,
    SampleStatus status,
  );
  Stream<Either<Failure, List<Sample>>> watchSamples();
  Stream<Either<Failure, List<Sample>>> watchSamplesByStatus(SampleStatus status);
  Future<Either<Failure, Sample>> getSampleById(String id);
  Future<Either<Failure, void>> updateSampleNote(String id, String note);
}
