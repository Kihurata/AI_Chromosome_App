import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class UpdateReportContent {
  final TestOrderRepository repository;

  UpdateReportContent(this.repository);

  Future<Either<Failure, void>> call(String orderId, String reportContent) {
    return repository.updateReportContent(orderId, reportContent);
  }
}
