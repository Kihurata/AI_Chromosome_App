import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: AppointmentRepository)
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Appointment>>> getTodayAppointments() async {
    try {
      final models = await remoteDataSource.getTodayAppointments();
      return Right(models.map((e) => _modelToEntity(e)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsInRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await remoteDataSource.getAppointmentsInRange(start, end);
      return Right(models.map((e) => _modelToEntity(e)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAppointment(
    Appointment appointment,
  ) async {
    try {
      final model = AppointmentModel.fromEntity(appointment);
      await remoteDataSource.createAppointment(model);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Appointment>>> watchTodayAppointments() {
    return remoteDataSource
        .watchTodayAppointments()
        .map<Either<Failure, List<Appointment>>>(
          (models) => Right(models.map(_modelToEntity).toList()),
        )
        .handleError(
          (error) => Left(ServerFailure(error.toString())),
        );
  }

  @override
  Future<Either<Failure, void>> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      await remoteDataSource.updateAppointmentStatus(
          appointmentId, status.toFirestoreString());
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }


  Appointment _modelToEntity(AppointmentModel model) {
    return model.toEntity();
  }
}
