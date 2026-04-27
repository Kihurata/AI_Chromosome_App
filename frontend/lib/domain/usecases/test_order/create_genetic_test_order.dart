import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

class CreateGeneticTestOrder {
  final TestOrderRepository repository;

  CreateGeneticTestOrder(this.repository);

  Future<Either<Failure, void>> call(TestOrder testOrder) {
    return repository.createTestOrder(testOrder);
  }
}
