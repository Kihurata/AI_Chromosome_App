import '../datasources/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentModel>> getTodayAppointments();
  Future<List<AppointmentModel>> getAppointmentsInRange(DateTime start, DateTime end);
  Future<void> scheduleAppointment(AppointmentModel appointment);
  Future<List<Map<String, dynamic>>> getAvailableDoctors();
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppointmentModel>> getTodayAppointments() {
    return remoteDataSource.getTodayAppointments();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsInRange(DateTime start, DateTime end) {
    return remoteDataSource.getAppointmentsInRange(start, end);
  }

  @override
  Future<void> scheduleAppointment(AppointmentModel appointment) {
    return remoteDataSource.createAppointment(appointment);
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableDoctors() {
    return remoteDataSource.getClinicians();
  }
}
