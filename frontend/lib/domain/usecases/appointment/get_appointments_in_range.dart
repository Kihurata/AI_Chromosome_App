import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class GetAppointmentsInRange {
  final AppointmentRepository repository;

  GetAppointmentsInRange(this.repository);

  Future<Either<Failure, List<Appointment>>> call(DateTime start, DateTime end) {
    return repository.getAppointmentsInRange(start, end);
  }
}
