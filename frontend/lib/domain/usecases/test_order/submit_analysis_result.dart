import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class SubmitAnalysisResult {
  final TestOrderRepository repository;

  SubmitAnalysisResult(this.repository);

  Future<Either<Failure, void>> call(String orderId) {
    return repository.updateOrderStatus(orderId, TestOrderStatus.waitingApproval);
  }
}
