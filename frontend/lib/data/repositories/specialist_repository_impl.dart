import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/specialist.dart';
import '../../domain/repositories/specialist_repository.dart';
import '../datasources/specialist_remote_datasource.dart';

@Injectable(as: SpecialistRepository)
class SpecialistRepositoryImpl implements SpecialistRepository {
  final SpecialistRemoteDataSource remoteDataSource;

  SpecialistRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Specialist>>> getSpecialists() async {
    try {
      final models = await remoteDataSource.getSpecialists();
      final specialists = models.map((map) {
        return Specialist(
          id: map['uid'],
          fullName: map['full_name'],
          email: map['email'],
        );
      }).toList();
      return Right(specialists);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Specialist>>> getAllSpecialists() async {
    return await getSpecialists();
  }
}
