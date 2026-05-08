import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class GetOrderById {
  final TestOrderRepository repository;

  GetOrderById(this.repository);

  Future<Either<Failure, TestOrder>> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}
