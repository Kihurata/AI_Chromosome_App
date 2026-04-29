import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class WatchAssignedOrders {
  final TestOrderRepository repository;

  WatchAssignedOrders(this.repository);

  Stream<Either<Failure, List<TestOrder>>> call(String specialistId) {
    return repository.watchAssignedOrders(specialistId);
  }
}
