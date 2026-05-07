import 'package:equatable/equatable.dart';
import '../../../domain/entities/patient.dart';
import '../../../../core/models/filter_options.dart';

abstract class PatientState extends Equatable {
  const PatientState();
  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final List<Patient> allPatients;
  final List<Patient> filteredPatients;
  final String searchQuery;
  final AppSortOrder sortOrder;
  final AppDateRangePreset dateRangePreset;

  const PatientLoaded({
    required this.allPatients,
    required this.filteredPatients,
    this.searchQuery = '',
    this.sortOrder = AppSortOrder.newest,
    this.dateRangePreset = AppDateRangePreset.all,
  });

  PatientLoaded copyWith({
    List<Patient>? allPatients,
    List<Patient>? filteredPatients,
    String? searchQuery,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
  }) {
    return PatientLoaded(
      allPatients: allPatients ?? this.allPatients,
      filteredPatients: filteredPatients ?? this.filteredPatients,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
    );
  }

  @override
  List<Object?> get props => [
        allPatients,
        filteredPatients,
        searchQuery,
        sortOrder,
        dateRangePreset,
      ];
}

class PatientActionSuccess extends PatientState {
  final String message;
  const PatientActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class PatientError extends PatientState {
  final String message;
  const PatientError(this.message);
  @override
  List<Object?> get props => [message];
}

class PatientDetailLoaded extends PatientState {
  final Patient patient;
  const PatientDetailLoaded(this.patient);
  @override
  List<Object?> get props => [patient];
}

class PatientDuplicateChecked extends PatientState {
  final Patient? existingPatient;
  const PatientDuplicateChecked(this.existingPatient);
  @override
  List<Object?> get props => [existingPatient];
}
