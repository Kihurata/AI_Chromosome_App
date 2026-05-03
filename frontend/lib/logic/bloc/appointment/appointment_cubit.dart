import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/appointment/create_appointment.dart';
import '../../../domain/usecases/appointment/get_today_appointments.dart';
import '../../../domain/usecases/appointment/get_appointments_in_range.dart';
import '../../../domain/usecases/appointment/watch_today_appointments.dart';
import '../../../domain/usecases/appointment/update_appointment_status.dart';
import '../../../domain/usecases/clinician/get_clinicians.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final CreateAppointment createAppointment;
  final GetTodayAppointments getTodayAppointments;
  final GetAppointmentsInRange getAppointmentsInRange;
  final WatchTodayAppointments watchTodayAppointments;
  final UpdateAppointmentStatus updateAppointmentStatus;
  final GetClinicians getClinicians;

  AppointmentCubit({
    required this.createAppointment,
    required this.getTodayAppointments,
    required this.getAppointmentsInRange,
    required this.watchTodayAppointments,
    required this.updateAppointmentStatus,
    required this.getClinicians,
  }) : super(AppointmentInitial());

  Future<void> fetchTodayAppointments() async {
    emit(AppointmentLoading());
    final result = await getTodayAppointments();
    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (appointments) => emit(AppointmentLoaded(appointments)),
    );
  }

  /// Listens to real-time Firestore updates via a Stream.
  /// Emits AppointmentLoading once, then re-emits every time
  /// Firestore pushes a new snapshot.
  Future<void> listenToTodayAppointments() async {
    emit(AppointmentLoading());
    await for (final result in watchTodayAppointments()) {
      if (isClosed) break;
      result.fold(
        (failure) => emit(AppointmentError(failure.message)),
        (appointments) => emit(AppointmentLoaded(appointments)),
      );
    }
  }

  /// Fetches appointments for a specific date range (used by Calendar page).
  /// Emits RangeAppointmentsLoaded to differentiate from today's list.
  Future<void> fetchAppointmentsInRange(DateTime start, DateTime end) async {
    emit(AppointmentLoading());
    final result = await getAppointmentsInRange(start, end);
    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (appointments) => emit(RangeAppointmentsLoaded(appointments)),
    );
  }

  Future<void> updateStatus(String appointmentId, AppointmentStatus status) async {
    final result = await updateAppointmentStatus(appointmentId, status);
    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (_) => null, // Stream listener will auto-refresh the list
    );
  }

  Future<void> startExamination(String appointmentId) =>
      updateStatus(appointmentId, AppointmentStatus.inProgress);

  Future<void> completeAppointment(String appointmentId) =>
      updateStatus(appointmentId, AppointmentStatus.completed);

  Future<void> cancelAppointment(String appointmentId) =>
      updateStatus(appointmentId, AppointmentStatus.cancelled);

  Future<void> fetchClinicians() async {
    emit(AppointmentLoading());
    final result = await getClinicians();
    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (clinicians) => emit(CliniciansLoaded(clinicians)),
    );
  }

  Future<void> addAppointment(Appointment appointment) async {
    emit(AppointmentLoading());
    final result = await createAppointment(appointment);
    result.fold(
      (failure) => emit(AppointmentError(failure.message)),
      (_) => emit(AppointmentSuccess("Tạo lịch hẹn thành công")),
    );
  }
}
