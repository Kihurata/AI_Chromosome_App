import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment.dart';

class AppointmentModel {
  final String id;
  final DocumentReference patientId;
  final String patientName;
  final DocumentReference doctorId;
  final String doctorName;
  final DateTime appointmentDate;
  final AppointmentStatus status;
  final String reason;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    this.status = AppointmentStatus.scheduled,
    required this.reason,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'appointment_date': Timestamp.fromDate(appointmentDate),
      'status': status.toFirestoreString(),
      'reason': reason,
    };
  }

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      patientId: data['patient_id'] as DocumentReference,
      patientName: data['patient_name'] ?? '',
      doctorId: data['doctor_id'] as DocumentReference,
      doctorName: data['doctor_name'] ?? '',
      appointmentDate: (data['appointment_date'] as Timestamp).toDate(),
      status: AppointmentStatus.fromString(data['status'] ?? 'SCHEDULED'),
      reason: data['reason'] ?? '',
    );
  }

  factory AppointmentModel.fromEntity(Appointment appointment) {
    final firestore = FirebaseFirestore.instance;
    return AppointmentModel(
      id: appointment.id,
      patientId: firestore.collection('patients').doc(appointment.patientId),
      patientName: appointment.patientName,
      doctorId: firestore.collection('users').doc(appointment.doctorId),
      doctorName: appointment.doctorName,
      appointmentDate: appointment.appointmentDate,
      status: appointment.status,
      reason: appointment.reason,
    );
  }

  Appointment toEntity() {
    return Appointment(
      id: id,
      patientId: patientId.id,
      patientName: patientName,
      doctorId: doctorId.id,
      doctorName: doctorName,
      appointmentDate: appointmentDate,
      status: status,
      reason: reason,
    );
  }
}
