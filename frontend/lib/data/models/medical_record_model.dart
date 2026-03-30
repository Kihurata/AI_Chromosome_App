import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordModel {
  final String id;
  final DocumentReference? appointmentId;
  final DocumentReference? patientId;
  final DocumentReference? doctorId;

  // General Exam
  final String? reason;
  
  // Vitals
  final int? pulse;
  final String? bloodPressure;
  final double? temperature;
  final double? weight;

  // Progression & Symptoms
  final String? pathologicalProcess;
  final String? physicalExamination;

  // Diagnosis (Preliminary)
  final String? icdCode;
  final String? icdName;

  // Notes
  final String? doctorNotes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicalRecordModel({
    required this.id,
    this.appointmentId,
    this.patientId,
    this.doctorId,
    this.reason,
    this.pulse,
    this.bloodPressure,
    this.temperature,
    this.weight,
    this.pathologicalProcess,
    this.physicalExamination,
    this.icdCode,
    this.icdName,
    this.doctorNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return MedicalRecordModel(
      id: doc.id,
      appointmentId: data?['appointment_id'] as DocumentReference?,
      patientId: data?['patient_id'] as DocumentReference?,
      doctorId: data?['doctor_id'] as DocumentReference?,
      reason: data?['reason'],
      pulse: data?['pulse'],
      bloodPressure: data?['blood_pressure'],
      temperature: (data?['temperature'] as num?)?.toDouble(),
      weight: (data?['weight'] as num?)?.toDouble(),
      pathologicalProcess: data?['pathological_process'],
      physicalExamination: data?['physical_examination'],
      icdCode: data?['icd_code'],
      icdName: data?['icd_name'],
      doctorNotes: data?['doctor_notes'],
      createdAt: (data?['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data?['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (appointmentId != null) 'appointment_id': appointmentId,
      if (patientId != null) 'patient_id': patientId,
      if (doctorId != null) 'doctor_id': doctorId,
      if (reason != null) 'reason': reason,
      if (pulse != null) 'pulse': pulse,
      if (bloodPressure != null) 'blood_pressure': bloodPressure,
      if (temperature != null) 'temperature': temperature,
      if (weight != null) 'weight': weight,
      if (pathologicalProcess != null) 'pathological_process': pathologicalProcess,
      if (physicalExamination != null) 'physical_examination': physicalExamination,
      if (icdCode != null) 'icd_code': icdCode,
      if (icdName != null) 'icd_name': icdName,
      if (doctorNotes != null) 'doctor_notes': doctorNotes,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
