import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/specialist.dart';

abstract class SpecialistRepository {
  Future<Either<Failure, List<Specialist>>> getSpecialists();
  Future<Either<Failure, List<Specialist>>> getAllSpecialists();
}
