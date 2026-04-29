import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

class SubmitResultForApproval {
  final WorkspaceRepository repository;

  SubmitResultForApproval(this.repository);

  Future<Either<Failure, void>> call(String orderId) {
    return repository.submitResultForApproval(orderId);
  }
}
