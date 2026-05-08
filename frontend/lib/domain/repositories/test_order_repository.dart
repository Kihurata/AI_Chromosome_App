import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/test_order.dart';

abstract class TestOrderRepository {
  Future<Either<Failure, void>> createTestOrder(TestOrder testOrder);
  Future<Either<Failure, List<TestOrder>>> getTestOrdersByClinician(
    String clinicianId,
  );
  Future<Either<Failure, List<TestOrder>>> getTestOrdersByPatient(
    String patientId,
  );
  Future<Either<Failure, List<TestOrder>>> getAllPendingOrders();
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    TestOrderStatus status, {
    String? reason,
  });
  Future<Either<Failure, void>> assignSpecialistToOrder(
    String orderId,
    String specialistId,
  );
  Stream<Either<Failure, List<TestOrder>>> watchAssignedOrders(
    String specialistId,
  );
  Stream<Either<Failure, List<TestOrder>>> watchAllOrders();
  Stream<Either<Failure, List<TestOrder>>> watchTestOrdersByPatient(String patientId);
  Future<Either<Failure, void>> updateOrderSpecialist(String orderId, String specialistId);
  Future<Either<Failure, void>> updateReportContent(String orderId, String reportContent);
}
