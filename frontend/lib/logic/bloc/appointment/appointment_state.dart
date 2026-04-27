import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const AppointmentLoaded(this.appointments);

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
