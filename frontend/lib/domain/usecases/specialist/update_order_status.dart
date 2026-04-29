import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class UpdateOrderStatus {
  final TestOrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<Either<Failure, void>> call(String orderId, TestOrderStatus status) {
    return repository.updateOrderStatus(orderId, status);
  }
}
