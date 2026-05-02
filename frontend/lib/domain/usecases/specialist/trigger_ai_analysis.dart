import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@lazySingleton
class TriggerAiAnalysis {
  final TestOrderRepository repository;

  TriggerAiAnalysis(this.repository);

  Future<Either<Failure, void>> call(String orderId) async {
    return await repository.updateOrderStatus(
      orderId,
      TestOrderStatus.analyzing,
    );
  }
}
