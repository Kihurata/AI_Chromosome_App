import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class GetTodayAppointments {
  final AppointmentRepository repository;

  GetTodayAppointments(this.repository);

  Future<Either<Failure, List<Appointment>>> call() {
    return repository.getTodayAppointments();
  }
}
