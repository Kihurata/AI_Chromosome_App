import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';
import '../../../../core/models/filter_options.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<Appointment> allAppointments;
  final List<Appointment> filteredAppointments;
  final String searchQuery;
  final AppSortOrder sortOrder;
  final AppDateRangePreset dateRangePreset;

  const AppointmentLoaded({
    required this.allAppointments,
    required this.filteredAppointments,
    this.searchQuery = '',
    this.sortOrder = AppSortOrder.newest,
    this.dateRangePreset = AppDateRangePreset.all,
  });

  AppointmentLoaded copyWith({
    List<Appointment>? allAppointments,
    List<Appointment>? filteredAppointments,
    String? searchQuery,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
  }) {
    return AppointmentLoaded(
      allAppointments: allAppointments ?? this.allAppointments,
      filteredAppointments: filteredAppointments ?? this.filteredAppointments,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
    );
  }

  @override
  List<Object?> get props => [
        allAppointments,
        filteredAppointments,
        searchQuery,
        sortOrder,
        dateRangePreset,
      ];
}

class RangeAppointmentsLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const RangeAppointmentsLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class CliniciansLoaded extends AppointmentState {
  final List<Map<String, dynamic>> clinicians;

  const CliniciansLoaded(this.clinicians);

  @override
  List<Object?> get props => [clinicians];
}

class AppointmentSuccess extends AppointmentState {
  final String message;

  const AppointmentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}
