import 'package:equatable/equatable.dart';
import '../../../data/models/patient_model.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final List<PatientModel> patients;
  final String? searchQuery;

  const PatientLoaded({required this.patients, this.searchQuery});

  @override
  List<Object?> get props => [patients, searchQuery];
}

class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object?> get props => [message];
}
