import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/workspace_repository.dart';

@lazySingleton
class TriggerAiAnalysis {
  final WorkspaceRepository repository;

  TriggerAiAnalysis(this.repository);

  Future<Either<Failure, void>> call(String orderId) async {
    return await repository.triggerAiAnalysis(orderId);
  }
}
