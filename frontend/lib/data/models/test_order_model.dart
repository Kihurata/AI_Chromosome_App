import 'package:cloud_firestore/cloud_firestore.dart';

class TestOrderModel {
  final String id;
  final DocumentReference patientId;
  final String patientName;
  final String patientCode;
  final DocumentReference appointmentId;
  final DocumentReference? specialistId;
  final String status;
  final DateTime createdAt;

  TestOrderModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientCode,
    required this.appointmentId,
    this.specialistId,
    this.status = 'PENDING',
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_code': patientCode,
      'appointment_id': appointmentId,
      'specialist_id': specialistId,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(createdAt),
    };
  }
}
