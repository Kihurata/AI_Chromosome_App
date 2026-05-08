import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/test_order.dart';

class TestOrderModel {
  final String id;
  final DocumentReference patientId;
  final String patientName;
  final String patientCode;
  final DocumentReference appointmentId;
  final DocumentReference? specialistId;
  final DocumentReference? clinicianId;
  final String status;
  final String? reportContent;
  final DateTime createdAt;

  TestOrderModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientCode,
    required this.appointmentId,
    this.specialistId,
    this.clinicianId,
    this.status = 'PENDING',
    this.reportContent,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_code': patientCode,
      'appointment_id': appointmentId,
      'specialist_id': specialistId,
      'clinician_id': clinicianId,
      'status': status,
      'report_content': reportContent,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(createdAt),
    };
  }

  factory TestOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final firestore = FirebaseFirestore.instance;
    return TestOrderModel(
      id: doc.id,
      patientId: data['patient_id'] as DocumentReference? ??
          firestore.collection('patients').doc('unknown'),
      patientName: data['patient_name'] ?? '',
      patientCode: data['patient_code'] ?? '',
      appointmentId: data['appointment_id'] as DocumentReference? ??
          firestore.collection('appointments').doc('unknown'),
      specialistId: data['specialist_id'] as DocumentReference?,
      clinicianId: data['clinician_id'] as DocumentReference?,
      status: data['status'] ?? 'PENDING',
      reportContent: data['report_content'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory TestOrderModel.fromEntity(TestOrder testOrder) {
    final firestore = FirebaseFirestore.instance;
    return TestOrderModel(
      id: testOrder.id,
      patientId: firestore.collection('patients').doc(testOrder.patientId),
      patientName: testOrder.patientName,
      patientCode: testOrder.patientCode,
      appointmentId:
          firestore.collection('appointments').doc(testOrder.appointmentId),
      specialistId: testOrder.specialistId != null
          ? firestore.collection('users').doc(testOrder.specialistId)
          : null,
      clinicianId: testOrder.clinicianId != null
          ? firestore.collection('users').doc(testOrder.clinicianId)
          : null,
      status: testOrder.status.toFirestoreString(),
      reportContent: testOrder.reportContent,
      createdAt: testOrder.createdAt,
    );
  }
}

