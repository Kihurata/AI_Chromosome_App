import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/specialist.dart';
import '../../repositories/specialist_repository.dart';

@injectable
class GetSpecialists {
  final SpecialistRepository repository;

  GetSpecialists(this.repository);

  Future<Either<Failure, List<Specialist>>> call() async {
    return await repository.getSpecialists();
  }
}
