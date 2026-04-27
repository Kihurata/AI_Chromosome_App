import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class ClinicianRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getClinicians();
}
