import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class UpdateAppointmentStatus {
  final AppointmentRepository repository;

  UpdateAppointmentStatus(this.repository);

  Future<Either<Failure, void>> call(
      String appointmentId, AppointmentStatus status) {
    return repository.updateAppointmentStatus(appointmentId, status);
  }
}
