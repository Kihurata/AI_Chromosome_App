import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

import 'package:injectable/injectable.dart';

@injectable
class WatchTodayAppointments {
  final AppointmentRepository repository;

  WatchTodayAppointments(this.repository);

  Stream<Either<Failure, List<Appointment>>> call() {
    return repository.watchTodayAppointments();
  }
}
