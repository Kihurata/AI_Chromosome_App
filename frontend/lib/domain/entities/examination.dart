import 'package:equatable/equatable.dart';

class Examination extends Equatable {
  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;

  // Triệu chứng lâm sàng
  final String? symptomLocation;
  final String? symptomDuration;
  final String? symptomSeverity;

  // Tiền sử & Dị ứng
  final String? medicalHistory;
  final String? allergies;
  final String? currentMedications;

  // Chẩn đoán
  final String? preliminaryDiagnosis;
  final String? icdCode;

  // Kết luận & Điều trị
  final String? conclusion;
  final String? treatmentPlan;
  final String? medicationNotes;
  final DateTime? followUpDate;
  final bool priorityFollowUp;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const Examination({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    this.symptomLocation,
    this.symptomDuration,
    this.symptomSeverity,
    this.medicalHistory,
    this.allergies,
    this.currentMedications,
    this.preliminaryDiagnosis,
    this.icdCode,
    this.conclusion,
    this.treatmentPlan,
    this.medicationNotes,
    this.followUpDate,
    this.priorityFollowUp = false,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        patientId,
        doctorId,
        symptomLocation,
        symptomDuration,
        symptomSeverity,
        medicalHistory,
        allergies,
        currentMedications,
        preliminaryDiagnosis,
        icdCode,
        conclusion,
        treatmentPlan,
        medicationNotes,
        followUpDate,
        priorityFollowUp,
        createdAt,
        updatedAt,
      ];
}
