import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/chromosome.dart';
import '../../repositories/workspace_repository.dart';

class UpdateChromosomePosition {
  final WorkspaceRepository repository;

  UpdateChromosomePosition(this.repository);

  Future<Either<Failure, void>> call(String orderId, Chromosome chromosome) {
    return repository.updateChromosomePosition(orderId, chromosome);
  }
}
