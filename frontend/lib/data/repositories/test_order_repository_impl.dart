import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/test_order.dart';
import '../../domain/repositories/test_order_repository.dart';
import '../datasources/test_order_remote_datasource.dart';
import '../models/test_order_model.dart';

import 'package:injectable/injectable.dart';

@Injectable(as: TestOrderRepository)
class TestOrderRepositoryImpl implements TestOrderRepository {
  final TestOrderRemoteDataSource remoteDataSource;

  TestOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createTestOrder(TestOrder testOrder) async {
    try {
      final model = TestOrderModel.fromEntity(testOrder);
      await remoteDataSource.createTestOrder(model);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TestOrder>>> getTestOrdersByClinician(
    String clinicianId,
  ) async {
    try {
      final models = await remoteDataSource.getTestOrdersByClinician(
        clinicianId,
      );
      return Right(models.map(_modelToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TestOrder>>> getAllPendingOrders() async {
    try {
      final models = await remoteDataSource.getAllPendingOrders();
      return Right(models.map(_modelToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    TestOrderStatus status, {
    String? reason,
  }) async {
    try {
      await remoteDataSource.updateOrderStatus(
        orderId,
        status.toFirestoreString(),
        reason: reason,
      );
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignSpecialistToOrder(
    String orderId,
    String specialistId,
  ) async {
    try {
      await remoteDataSource.assignSpecialistToOrder(orderId, specialistId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<TestOrder>>> watchAssignedOrders(
    String specialistId,
  ) async* {
    try {
      yield* remoteDataSource
          .watchAssignedOrders(specialistId)
          .map<Either<Failure, List<TestOrder>>>((models) {
            return Right(models.map(_modelToEntity).toList());
          });
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<TestOrder>>> watchAllOrders() async* {
    try {
      yield* remoteDataSource
          .watchAllOrders()
          .map<Either<Failure, List<TestOrder>>>((models) {
            return Right(models.map(_modelToEntity).toList());
          });
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<TestOrder>>> watchTestOrdersByPatient(String patientId) async* {
    try {
      yield* remoteDataSource.watchTestOrdersByPatient(patientId).map<
          Either<Failure, List<TestOrder>>>((models) {
        return Right(models.map(_modelToEntity).toList());
      });
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  TestOrder _modelToEntity(TestOrderModel model) {
    return TestOrder(
      id: model.id,
      patientId: model.patientId.id,
      patientName: model.patientName,
      patientCode: model.patientCode,
      appointmentId: model.appointmentId.id,
      specialistId: model.specialistId?.id,
      clinicianId: model.clinicianId?.id,
      status: TestOrderStatus.fromString(model.status),
      createdAt: model.createdAt,
    );
  }

  @override
  Future<Either<Failure, List<TestOrder>>> getTestOrdersByPatient(String patientId) async {
    try {
      final models = await remoteDataSource.getTestOrdersByPatient(patientId);
      return Right(models.map(_modelToEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderSpecialist(String orderId, String specialistId) async {
    try {
      await remoteDataSource.updateOrderSpecialist(orderId, specialistId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
