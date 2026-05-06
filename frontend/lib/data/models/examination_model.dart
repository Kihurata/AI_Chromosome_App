import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/examination.dart';

class ExaminationModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;

  final String? symptomLocation;
  final String? symptomDuration;
  final String? symptomSeverity;
  final String? medicalHistory;
  final String? allergies;
  final String? currentMedications;
  final String? preliminaryDiagnosis;
  final String? icdCode;
  final String? conclusion;
  final String? treatmentPlan;
  final String? medicationNotes;
  final DateTime? followUpDate;
  final bool priorityFollowUp;

  final DateTime createdAt;
  final DateTime? updatedAt;

  ExaminationModel({
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

  Map<String, dynamic> toFirestore() {
    return {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'symptom_location': symptomLocation,
      'symptom_duration': symptomDuration,
      'symptom_severity': symptomSeverity,
      'medical_history': medicalHistory,
      'allergies': allergies,
      'current_medications': currentMedications,
      'preliminary_diagnosis': preliminaryDiagnosis,
      'icd_code': icdCode,
      'conclusion': conclusion,
      'treatment_plan': treatmentPlan,
      'medication_notes': medicationNotes,
      'follow_up_date':
          followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'priority_follow_up': priorityFollowUp,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ExaminationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExaminationModel(
      id: doc.id,
      appointmentId: data['appointment_id'] ?? '',
      patientId: data['patient_id'] ?? '',
      doctorId: data['doctor_id'] ?? '',
      symptomLocation: data['symptom_location'],
      symptomDuration: data['symptom_duration'],
      symptomSeverity: data['symptom_severity'],
      medicalHistory: data['medical_history'],
      allergies: data['allergies'],
      currentMedications: data['current_medications'],
      preliminaryDiagnosis: data['preliminary_diagnosis'],
      icdCode: data['icd_code'],
      conclusion: data['conclusion'],
      treatmentPlan: data['treatment_plan'],
      medicationNotes: data['medication_notes'],
      followUpDate:
          (data['follow_up_date'] as Timestamp?)?.toDate(),
      priorityFollowUp: data['priority_follow_up'] ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  factory ExaminationModel.fromEntity(Examination examination) {
    return ExaminationModel(
      id: examination.id,
      appointmentId: examination.appointmentId,
      patientId: examination.patientId,
      doctorId: examination.doctorId,
      symptomLocation: examination.symptomLocation,
      symptomDuration: examination.symptomDuration,
      symptomSeverity: examination.symptomSeverity,
      medicalHistory: examination.medicalHistory,
      allergies: examination.allergies,
      currentMedications: examination.currentMedications,
      preliminaryDiagnosis: examination.preliminaryDiagnosis,
      icdCode: examination.icdCode,
      conclusion: examination.conclusion,
      treatmentPlan: examination.treatmentPlan,
      medicationNotes: examination.medicationNotes,
      followUpDate: examination.followUpDate,
      priorityFollowUp: examination.priorityFollowUp,
      createdAt: examination.createdAt,
      updatedAt: examination.updatedAt,
    );
  }

  Examination toEntity() {
    return Examination(
      id: id,
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
