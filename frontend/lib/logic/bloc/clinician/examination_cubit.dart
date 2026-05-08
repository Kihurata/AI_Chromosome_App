import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/examination.dart';
import '../../../domain/usecases/clinician/create_examination.dart';
import '../../../domain/usecases/clinician/get_examinations_by_patient.dart';
import '../../../../core/models/filter_options.dart';
import 'examination_state.dart';

import '../../../domain/usecases/appointment/update_appointment_status.dart';
import '../../../../domain/entities/appointment.dart';

@injectable
class ExaminationCubit extends Cubit<ExaminationState> {
  final CreateExamination createExaminationUsecase;
  final GetExaminationsByPatient getExaminationsUsecase;
  final UpdateAppointmentStatus updateAppointmentStatusUsecase;

  ExaminationCubit({
    required this.createExaminationUsecase,
    required this.getExaminationsUsecase,
    required this.updateAppointmentStatusUsecase,
  }) : super(ExaminationInitial());

  Future<void> loadExaminations(String patientId) async {
    emit(ExaminationLoading());
    final result = await getExaminationsUsecase(patientId);
    result.fold(
      (failure) => emit(ExaminationError(failure.message)),
      (examinations) {
        String currentSearch = '';
        AppSortOrder currentSort = AppSortOrder.newest;
        AppDateRangePreset currentDate = AppDateRangePreset.all;

        if (state is ExaminationLoaded) {
          final s = state as ExaminationLoaded;
          currentSearch = s.searchQuery;
          currentSort = s.sortOrder;
          currentDate = s.dateRangePreset;
        }

        final filtered = _applyFilters(
          examinations,
          currentSearch,
          currentSort,
          currentDate,
        );

        emit(ExaminationLoaded(
          allExaminations: examinations,
          filteredExaminations: filtered,
          searchQuery: currentSearch,
          sortOrder: currentSort,
          dateRangePreset: currentDate,
        ));
      },
    );
  }

  void updateFilters({
    String? searchQuery,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
  }) {
    if (state is! ExaminationLoaded) return;
    final s = state as ExaminationLoaded;

    final newQuery = searchQuery ?? s.searchQuery;
    final newSort = sortOrder ?? s.sortOrder;
    final newDate = dateRangePreset ?? s.dateRangePreset;

    final filtered = _applyFilters(
      s.allExaminations,
      newQuery,
      newSort,
      newDate,
    );

    emit(s.copyWith(
      searchQuery: newQuery,
      sortOrder: newSort,
      dateRangePreset: newDate,
      filteredExaminations: filtered,
    ));
  }

  void setSearchQuery(String query) => updateFilters(searchQuery: query);

  List<Examination> _applyFilters(
    List<Examination> examinations,
    String query,
    AppSortOrder sortOrder,
    AppDateRangePreset dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = examinations.where((exam) {
      final matchesSearch = query.isEmpty ||
          (exam.preliminaryDiagnosis?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (exam.symptomLocation?.toLowerCase().contains(query.toLowerCase()) ?? false);

      bool matchesDate = true;
      if (dateRange != AppDateRangePreset.all) {
        final examDate = exam.createdAt;
        if (dateRange == AppDateRangePreset.today) {
          matchesDate = examDate.isAfter(today);
        } else if (dateRange == AppDateRangePreset.last7Days) {
          matchesDate = examDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (dateRange == AppDateRangePreset.last30Days) {
          matchesDate = examDate.isAfter(now.subtract(const Duration(days: 30)));
        }
      }

      return matchesSearch && matchesDate;
    }).toList();

    if (sortOrder == AppSortOrder.newest) {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return filtered;
  }

  Future<void> saveExamination(Examination examination) async {
    emit(ExaminationLoading());
    final result = await createExaminationUsecase(examination);
    result.fold(
      (failure) => emit(ExaminationError(failure.message)),
      (_) => emit(const ExaminationSaveSuccess('Lưu kết quả khám bệnh thành công')),
    );
  }

  Future<void> completeExamination({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    String? symptomLocation,
    String? symptomDuration,
    String? symptomSeverity,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
    String? preliminaryDiagnosis,
    String? icdCode,
    String? conclusion,
    String? treatmentPlan,
    String? medicationNotes,
    DateTime? followUpDate,
    bool? priorityFollowUp,
  }) async {
    emit(ExaminationLoading());

    final examination = Examination(
      id: '', // Will be generated by Firestore
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      symptomLocation: symptomLocation,
      symptomDuration: symptomDuration,
      symptomSeverity: symptomSeverity,
      medicalHistory: medicalHistory,
      allergies: allergies,
      currentMedications: currentMedications,
      preliminaryDiagnosis: preliminaryDiagnosis,
      icdCode: icdCode,
      conclusion: conclusion,
      treatmentPlan: treatmentPlan,
      medicationNotes: medicationNotes,
      followUpDate: followUpDate,
      priorityFollowUp: priorityFollowUp ?? false,
      createdAt: DateTime.now(),
    );

    final result = await createExaminationUsecase(examination);
    
    await result.fold(
      (failure) async => emit(ExaminationError(failure.message)),
      (_) async {
        // Cập nhật trạng thái lịch hẹn thành completed
        final updateResult = await updateAppointmentStatusUsecase(appointmentId, AppointmentStatus.completed);
        updateResult.fold(
          (failure) => emit(ExaminationError('Lưu khám bệnh thành công nhưng lỗi cập nhật lịch hẹn: ${failure.message}')),
          (_) => emit(const ExaminationSaveSuccess('Hoàn tất khám bệnh thành công')),
        );
      },
    );
  }

  Future<bool> saveBeforeOrderingTest({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    String? symptomLocation,
    String? symptomDuration,
    String? symptomSeverity,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
    String? preliminaryDiagnosis,
    String? icdCode,
  }) async {
    emit(ExaminationLoading());

    final examination = Examination(
      id: '',
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      symptomLocation: symptomLocation,
      symptomDuration: symptomDuration,
      symptomSeverity: symptomSeverity,
      medicalHistory: medicalHistory,
      allergies: allergies,
      currentMedications: currentMedications,
      preliminaryDiagnosis: preliminaryDiagnosis,
      icdCode: icdCode,
      createdAt: DateTime.now(),
    );

    final result = await createExaminationUsecase(examination);
    
    return result.fold(
      (failure) {
        emit(ExaminationError(failure.message));
        return false;
      },
      (_) {
        emit(const ExaminationSaveSuccess('Đã lưu thông tin khám bệnh tạm thời'));
        return true;
      },
    );
  }

  Future<void> cancelExamination(String appointmentId) async {
    emit(ExaminationLoading());
    final result = await updateAppointmentStatusUsecase(appointmentId, AppointmentStatus.cancelled);
    result.fold(
      (failure) => emit(ExaminationError(failure.message)),
      (_) => emit(const ExaminationSaveSuccess('Đã hủy lịch hẹn khám')),
    );
  }
}
