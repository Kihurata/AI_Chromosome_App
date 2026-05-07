import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class CreateAppointment {
  final AppointmentRepository repository;

  CreateAppointment(this.repository);

  Future<Either<Failure, void>> call(Appointment appointment) {
    return repository.createAppointment(appointment);
  }
}
