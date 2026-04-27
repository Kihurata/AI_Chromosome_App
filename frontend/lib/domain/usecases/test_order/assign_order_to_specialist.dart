import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/test_order_repository.dart';

class AssignOrderToSpecialist {
  final TestOrderRepository repository;

  AssignOrderToSpecialist(this.repository);

  Future<Either<Failure, void>> call({
    required String orderId,
    required String specialistId,
  }) {
    return repository.assignSpecialistToOrder(orderId, specialistId);
  }
}
