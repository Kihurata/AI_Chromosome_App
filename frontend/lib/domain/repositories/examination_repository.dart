import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/examination.dart';

abstract class ExaminationRepository {
  Future<Either<Failure, void>> createExamination(Examination examination);
  Future<Either<Failure, Examination?>> getExaminationByAppointmentId(String appointmentId);
  Future<Either<Failure, List<Examination>>> getExaminationsByPatientId(String patientId);
}
