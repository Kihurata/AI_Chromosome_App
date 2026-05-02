import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/test_order.dart';

abstract class TestOrderRepository {
  Future<Either<Failure, void>> createTestOrder(TestOrder testOrder);
  Future<Either<Failure, List<TestOrder>>> getTestOrdersByClinician(
    String clinicianId,
  );
  Future<Either<Failure, List<TestOrder>>> getAllPendingOrders();
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    TestOrderStatus status,
  );
  Future<Either<Failure, void>> assignSpecialistToOrder(
    String orderId,
    String specialistId,
  );
  Stream<Either<Failure, List<TestOrder>>> watchAssignedOrders(
    String specialistId,
  );
}
