import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/test_order.dart';

abstract class TestOrderRepository {
  Future<Either<Failure, void>> createTestOrder(TestOrder testOrder);
  Future<Either<Failure, List<TestOrder>>> getTestOrdersByClinician(
    String clinicianId,
  );
}
