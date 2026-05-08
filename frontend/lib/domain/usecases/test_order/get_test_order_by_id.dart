import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class GetTestOrderById {
  final TestOrderRepository repository;

  GetTestOrderById(this.repository);

  Future<Either<Failure, TestOrder>> call(String id) async {
    // Since repository doesn't have getById, we fetch all and find
    // In a real app, we should add getById to repository
    final result = await repository.watchAllOrders().first;
    return result.fold(
      (l) => Left(l),
      (orders) {
        try {
          final order = orders.firstWhere((o) => o.id == id);
          return Right(order);
        } catch (e) {
          return Left(ServerFailure('Không tìm thấy phiếu xét nghiệm #$id'));
        }
      },
    );
  }
}
