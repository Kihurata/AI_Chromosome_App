import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/patient.dart';
import '../../../domain/usecases/patient/get_patients.dart';
import '../../../domain/usecases/patient/add_patient.dart';
import '../../../domain/usecases/patient/update_patient.dart';
import '../../../domain/usecases/patient/get_patient_by_id.dart';
import '../../../domain/usecases/patient/get_patient_by_code.dart';
import '../../../domain/usecases/patient/watch_patients.dart';
import '../../../domain/usecases/patient/check_duplicate_patient.dart';
import '../../../../core/models/filter_options.dart';
import 'patient_state.dart';

@injectable
class PatientCubit extends Cubit<PatientState> {
  final GetPatients getPatientsUsecase;
  final AddPatient addPatientUsecase;
  final UpdatePatient updatePatientUsecase;
  final GetPatientById getPatientByIdUsecase;
  final GetPatientByCode getPatientByCodeUsecase;
  final WatchPatients watchPatientsUsecase;
  final CheckDuplicatePatient checkDuplicatePatientUsecase;

  PatientCubit({
    required this.getPatientsUsecase,
    required this.addPatientUsecase,
    required this.updatePatientUsecase,
    required this.getPatientByIdUsecase,
    required this.getPatientByCodeUsecase,
    required this.watchPatientsUsecase,
    required this.checkDuplicatePatientUsecase,
  }) : super(PatientInitial());

  Future<void> loadPatients() async {
    emit(PatientLoading());
    await for (final result in watchPatientsUsecase()) {
      if (isClosed) break;
      result.fold(
        (failure) => emit(PatientError(failure.message)),
        (patients) {
          String currentSearch = '';
          AppSortOrder currentSort = AppSortOrder.newest;
          AppDateRangePreset currentDate = AppDateRangePreset.all;

          if (state is PatientLoaded) {
            final s = state as PatientLoaded;
            currentSearch = s.searchQuery;
            currentSort = s.sortOrder;
            currentDate = s.dateRangePreset;
          }

          final filtered = _applyFilters(
            patients,
            currentSearch,
            currentSort,
            currentDate,
          );

          emit(PatientLoaded(
            allPatients: patients,
            filteredPatients: filtered,
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
    if (state is! PatientLoaded) return;
    final s = state as PatientLoaded;

    final newQuery = searchQuery ?? s.searchQuery;
    final newSort = sortOrder ?? s.sortOrder;
    final newDate = dateRangePreset ?? s.dateRangePreset;

    final filtered = _applyFilters(
      s.allPatients,
      newQuery,
      newSort,
      newDate,
    );

    emit(s.copyWith(
      searchQuery: newQuery,
      sortOrder: newSort,
      dateRangePreset: newDate,
      filteredPatients: filtered,
    ));
  }

  void setSearchQuery(String query) => updateFilters(searchQuery: query);

  List<Patient> _applyFilters(
    List<Patient> patients,
    String query,
    AppSortOrder sortOrder,
    AppDateRangePreset dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = patients.where((patient) {
      final matchesSearch = query.isEmpty ||
          patient.fullName.toLowerCase().contains(query.toLowerCase()) ||
          (patient.patientCode?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          patient.phone.contains(query);

      bool matchesDate = true;
      if (dateRange != AppDateRangePreset.all) {
        final regDate = patient.createdAt ?? DateTime.now();
        if (dateRange == AppDateRangePreset.today) {
          matchesDate = regDate.isAfter(today);
        } else if (dateRange == AppDateRangePreset.last7Days) {
          matchesDate = regDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (dateRange == AppDateRangePreset.last30Days) {
          matchesDate = regDate.isAfter(now.subtract(const Duration(days: 30)));
        }
      }

      return matchesSearch && matchesDate;
    }).toList();

    if (sortOrder == AppSortOrder.newest) {
      filtered.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    } else {
      filtered.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
    }

    return filtered;
  }

  Future<void> addPatient(Patient patient) async {
    emit(PatientLoading());
    final result = await addPatientUsecase(patient);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(const PatientActionSuccess('Thêm bệnh nhân thành công')),
    );
  }

  Future<void> updatePatient(Patient patient) async {
    emit(PatientLoading());
    final result = await updatePatientUsecase(patient);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(const PatientActionSuccess('Cập nhật bệnh nhân thành công')),
    );
  }

  Future<void> getPatientDetail(String id) async {
    emit(PatientLoading());
    final result = await getPatientByIdUsecase(id);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientDetailLoaded(patient)),
    );
  }

  Future<void> fetchPatients() => loadPatients();
  Future<void> createPatient(Patient patient) => addPatient(patient);
  Future<void> checkDuplicate({String? identityCard, String? phone}) => checkDuplicatePatient(identityCard: identityCard, phone: phone);
  Future<void> getPatientById(String id) => getPatientDetail(id);

  Future<void> checkDuplicatePatient({String? identityCard, String? phone}) async {
    final result = await checkDuplicatePatientUsecase(identityCard: identityCard, phone: phone);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientDuplicateChecked(patient)),
    );
  }
}
