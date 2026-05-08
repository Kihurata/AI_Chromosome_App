import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/test_order.dart';
import '../../repositories/test_order_repository.dart';

@injectable
class GetTestOrdersByPatient {
  final TestOrderRepository repository;

  GetTestOrdersByPatient(this.repository);

  Future<Either<Failure, List<TestOrder>>> call(String patientId) async {
    return await repository.getTestOrdersByPatient(patientId);
  }
}
