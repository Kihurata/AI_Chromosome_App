import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/chromosome.dart';
import '../../repositories/workspace_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class UpdateChromosomePosition {
  final WorkspaceRepository repository;

  UpdateChromosomePosition(this.repository);

  Future<Either<Failure, void>> call(String orderId, String imageId, Chromosome chromosome) {
    return repository.updateChromosomePosition(orderId, imageId, chromosome);
  }
}
