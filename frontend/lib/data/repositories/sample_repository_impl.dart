import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/sample.dart';
import '../../domain/repositories/sample_repository.dart';
import '../datasources/sample_remote_datasource.dart';
import '../models/sample_model.dart';

class SampleRepositoryImpl implements SampleRepository {
  final SampleRemoteDataSource remoteDataSource;

  SampleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createSample(Sample sample) async {
    try {
      final model = SampleModel.fromEntity(sample);
      await remoteDataSource.createSample(model);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSampleStatus(
    String sampleId,
    SampleStatus status,
  ) async {
    try {
      await remoteDataSource.updateSampleStatus(
        sampleId,
        status.toFirestoreString(),
      );
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
