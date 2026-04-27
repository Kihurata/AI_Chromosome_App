import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/clinician_repository.dart';
import '../datasources/clinician_remote_datasource.dart';

class ClinicianRepositoryImpl implements ClinicianRepository {
  final ClinicianRemoteDataSource remoteDataSource;

  ClinicianRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getClinicians() async {
    try {
      final clinicians = await remoteDataSource.getClinicians();
      return Right(clinicians);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
