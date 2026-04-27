import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

class GetAllPendingOrders {
  final TestOrderRepository repository;

  GetAllPendingOrders(this.repository);

  Future<Either<Failure, List<TestOrder>>> call() {
    return repository.getAllPendingOrders();
  }
}
