import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/examination.dart';
import '../../domain/repositories/examination_repository.dart';
import '../datasources/examination_remote_datasource.dart';
import '../models/examination_model.dart';

@LazySingleton(as: ExaminationRepository)
class ExaminationRepositoryImpl implements ExaminationRepository {
  final ExaminationRemoteDataSource remoteDataSource;

  ExaminationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> createExamination(Examination examination) async {
    try {
      final model = ExaminationModel.fromEntity(examination);
      await remoteDataSource.createExamination(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Examination?>> getExaminationByAppointmentId(
      String appointmentId) async {
    try {
      final model = await remoteDataSource.getExaminationByAppointmentId(appointmentId);
      if (model == null) return const Right(null);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Examination>>> getExaminationsByPatientId(
      String patientId) async {
    try {
      final models = await remoteDataSource.getExaminationsByPatientId(patientId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
