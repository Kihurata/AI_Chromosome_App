import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final DocumentReference patientId;
  final String patientName;
  final DocumentReference doctorId;
  final String doctorName;
  final DateTime appointmentDate;
  final String status;
  final String reason;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    this.status = 'scheduled',
    required this.reason,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'appointment_date': Timestamp.fromDate(appointmentDate),
      'status': status,
      'reason': reason,
    };
  }
}
