import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/appointment/create_appointment.dart';
import '../../../domain/usecases/appointment/get_today_appointments.dart';
import '../../../domain/usecases/clinician/get_clinicians.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final CreateAppointment createAppointment;
  final GetTodayAppointments getTodayAppointments;
  final GetClinicians getClinicians;

  AppointmentCubit({
    required this.createAppointment,
    required this.getTodayAppointments,
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
