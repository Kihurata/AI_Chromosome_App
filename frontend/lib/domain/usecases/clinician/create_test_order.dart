import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class CreateTestOrder {
  final TestOrderRepository repository;

  CreateTestOrder(this.repository);

  Future<Either<Failure, void>> call(TestOrder order) async {
    return await repository.createTestOrder(order);
  }
}
