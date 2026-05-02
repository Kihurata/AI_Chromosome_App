import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class RejectKaryotypeResult {
  final TestOrderRepository repository;

  RejectKaryotypeResult(this.repository);

  Future<Either<Failure, void>> call(String orderId, String reason) {
    return repository.updateOrderStatus(
      orderId,
      TestOrderStatus.rejected,
      reason: reason,
    );
  }
}
