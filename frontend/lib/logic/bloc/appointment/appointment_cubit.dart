import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/appointment/create_appointment.dart';
import '../../../domain/usecases/appointment/get_today_appointments.dart';
import '../../../domain/usecases/appointment/get_appointments_in_range.dart';
import '../../../domain/usecases/appointment/watch_today_appointments.dart';
import '../../../domain/usecases/appointment/update_appointment_status.dart';
import '../../../domain/usecases/clinician/get_clinicians.dart';
import '../../../../core/models/filter_options.dart';
import 'appointment_state.dart';

@injectable
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
      (appointments) {
        final filtered = _applyFilters(
          appointments,
          '',
          AppSortOrder.newest,
          AppDateRangePreset.all,
        );
        emit(AppointmentLoaded(
          allAppointments: appointments,
          filteredAppointments: filtered,
        ));
      },
    );
  }

  Future<void> listenToTodayAppointments() async {
    emit(AppointmentLoading());
    await for (final result in watchTodayAppointments()) {
      if (isClosed) break;
      result.fold(
        (failure) => emit(AppointmentError(failure.message)),
        (appointments) {
          String currentSearch = '';
          AppSortOrder currentSort = AppSortOrder.newest;
          AppDateRangePreset currentDate = AppDateRangePreset.all;

          if (state is AppointmentLoaded) {
            final s = state as AppointmentLoaded;
            currentSearch = s.searchQuery;
            currentSort = s.sortOrder;
            currentDate = s.dateRangePreset;
          }

          final filtered = _applyFilters(
            appointments,
            currentSearch,
            currentSort,
            currentDate,
          );

          emit(AppointmentLoaded(
            allAppointments: appointments,
            filteredAppointments: filtered,
            searchQuery: currentSearch,
            sortOrder: currentSort,
            dateRangePreset: currentDate,
          ));
        },
      );
    }
  }

  void updateFilters({
    String? searchQuery,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
  }) {
    if (state is! AppointmentLoaded) return;
    final s = state as AppointmentLoaded;

    final newQuery = searchQuery ?? s.searchQuery;
    final newSort = sortOrder ?? s.sortOrder;
    final newDate = dateRangePreset ?? s.dateRangePreset;

    final filtered = _applyFilters(
      s.allAppointments,
      newQuery,
      newSort,
      newDate,
    );

    emit(s.copyWith(
      searchQuery: newQuery,
      sortOrder: newSort,
      dateRangePreset: newDate,
      filteredAppointments: filtered,
    ));
  }

  void setSearchQuery(String query) => updateFilters(searchQuery: query);

  List<Appointment> _applyFilters(
    List<Appointment> appointments,
    String query,
    AppSortOrder sortOrder,
    AppDateRangePreset dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = appointments.where((appointment) {
      final matchesSearch = query.isEmpty ||
          appointment.patientName.toLowerCase().contains(query.toLowerCase()) ||
          (appointment.patientCode?.toLowerCase().contains(query.toLowerCase()) ?? false);

      bool matchesDate = true;
      if (dateRange != AppDateRangePreset.all) {
        final appDate = appointment.appointmentDate;
        if (dateRange == AppDateRangePreset.today) {
          matchesDate = appDate.isAfter(today);
        } else if (dateRange == AppDateRangePreset.last7Days) {
          matchesDate = appDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (dateRange == AppDateRangePreset.last30Days) {
          matchesDate = appDate.isAfter(now.subtract(const Duration(days: 30)));
        }
      }

      return matchesSearch && matchesDate;
    }).toList();

    if (sortOrder == AppSortOrder.newest) {
      filtered.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    } else {
      filtered.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    }

    return filtered;
  }

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
      (_) => null,
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
