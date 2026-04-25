import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';
import '../models/patient_model.dart';

@LazySingleton(as: PatientRepository)
class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Patient>>> getPatients() async {
    try {
      final remotePatients = await remoteDataSource.getPatients();
      return Right(remotePatients);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(
        ServerFailure('Không thể lấy được danh sách bệnh nhân'),
      );
    }
  }

  @override
  Future<Either<Failure, Patient>> getPatientById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> addPatient(Patient patient) async {
    try {
      final model = PatientModel.fromEntity(patient);
      await remoteDataSource.addPatient(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Không thể thêm bệnh nhân'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePatient(Patient patient) async {
    try {
      // Tương tự như add, chúng ta cần Model để update
      final model = PatientModel.fromEntity(patient);
      await remoteDataSource.updatePatient(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(
        ServerFailure('Lỗi không thể cập nhật thông tin bệnh nhân'),
      );
    }
  }
}
