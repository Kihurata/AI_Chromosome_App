import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<Appointment>>> getTodayAppointments();
  Stream<Either<Failure, List<Appointment>>> watchTodayAppointments();
  Future<Either<Failure, List<Appointment>>> getAppointmentsInRange(DateTime start, DateTime end);
  Future<Either<Failure, void>> createAppointment(Appointment appointment);
  Future<Either<Failure, void>> updateAppointmentStatus(String appointmentId, String status);
}
