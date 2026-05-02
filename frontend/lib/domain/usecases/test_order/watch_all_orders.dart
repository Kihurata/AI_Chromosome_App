import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class WatchAllOrders {
  final TestOrderRepository repository;

  WatchAllOrders(this.repository);

  Stream<Either<Failure, List<TestOrder>>> call() {
    return repository.watchAllOrders();
  }
}
