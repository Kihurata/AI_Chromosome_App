import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/entities/examination.dart';
import '../../../domain/usecases/clinician/create_examination.dart';
import '../../../domain/usecases/appointment/update_appointment_status.dart';
import '../../../domain/usecases/clinician/get_examinations_by_patient.dart';
import 'examination_state.dart';

import 'package:injectable/injectable.dart';

@injectable
class ExaminationCubit extends Cubit<ExaminationState> {
  final CreateExamination createExamination;
  final UpdateAppointmentStatus updateAppointmentStatus;
  final GetExaminationsByPatient getExaminationsByPatient;

  ExaminationCubit({
    required this.createExamination,
    required this.updateAppointmentStatus,
    required this.getExaminationsByPatient,
  }) : super(ExaminationInitial());

  /// Lưu phiếu khám bệnh (không thay đổi status)
  Future<bool> saveExamination({
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
    bool priorityFollowUp = false,
  }) async {
    emit(ExaminationLoading());
    final examination = Examination(
      id: const Uuid().v4(),
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: doctorId,
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
      priorityFollowUp: priorityFollowUp,
      createdAt: DateTime.now(),
    );
    final result = await createExamination(examination);
    return result.fold(
      (failure) {
        emit(ExaminationError(failure.message));
        return false;
      },
      (_) => true,
    );
  }

  /// Lưu phiếu khám + đổi status thành completed
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
    bool priorityFollowUp = false,
  }) async {
    emit(ExaminationLoading());

    final saved = await saveExamination(
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: doctorId,
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
      priorityFollowUp: priorityFollowUp,
    );

    if (!saved) return;

    final statusResult = await updateAppointmentStatus(
        appointmentId, AppointmentStatus.completed);
    statusResult.fold(
      (failure) => emit(ExaminationError(failure.message)),
      (_) => emit(const ExaminationSaveSuccess('Phiếu khám đã được lưu thành công!')),
    );
  }

  /// Hủy khám — chỉ đổi status, không cần lưu phiếu
  Future<void> cancelExamination(String appointmentId) async {
    emit(ExaminationLoading());
    final result = await updateAppointmentStatus(
        appointmentId, AppointmentStatus.cancelled);
    result.fold(
      (failure) => emit(ExaminationError(failure.message)),
      (_) => emit(const ExaminationSaveSuccess('Lịch khám đã được hủy.')),
    );
  }

  /// Lưu tạm phiếu khám khi chuyển sang tạo phiếu xét nghiệm
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
  }) {
    return saveExamination(
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: doctorId,
      symptomLocation: symptomLocation,
      symptomDuration: symptomDuration,
      symptomSeverity: symptomSeverity,
      medicalHistory: medicalHistory,
      allergies: allergies,
      currentMedications: currentMedications,
      preliminaryDiagnosis: preliminaryDiagnosis,
      icdCode: icdCode,
    );
  }

  /// Tải danh sách lịch sử khám theo bệnh nhân
  Future<void> loadExaminationsByPatient(String patientId) async {
    emit(ExaminationLoading());
    final result = await getExaminationsByPatient(patientId);
    result.fold(
      (failure) => emit(ExaminationError(failure.message)),
      (examinations) => emit(ExaminationLoaded(examinations)),
    );
  }
}
