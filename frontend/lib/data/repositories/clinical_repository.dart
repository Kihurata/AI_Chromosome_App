import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/test_order_model.dart';
import '../models/patient_model.dart';

class ClinicalRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Giai đoạn 1: Đặt lịch & Thăm khám (Clinical Stage)
  
  // Hành động: Tạo patient mới
  Future<String> createPatient(PatientModel patient) async {
    final docRef = await _db.collection('patients').add(patient.toFirestore());
    return docRef.id;
  }

  // Hành động: Tạo appointment mới
  Future<String> createAppointment(AppointmentModel appointment) async {
    final docRef = await _db.collection('appointments').add(appointment.toFirestore());
    return docRef.id;
  }

  // Gộp: Tạo BN và Lịch hẹn đồng thời
  Future<void> registerPatientWithAppointment(PatientModel patient, Map<String, dynamic> apptData) async {
    // 1. Create Patient
    final patientIdStr = await createPatient(patient);
    final patientRef = _db.doc('patients/$patientIdStr');

    // 2. Create Appointment
    final appointment = AppointmentModel(
      id: '', // Firestore will generate
      patientId: patientRef,
      patientName: patient.fullName,
      doctorId: _db.doc('doctors/${apptData['doctor_uid']}'),
      doctorName: apptData['doctor_name'],
      appointmentDate: apptData['date'],
      reason: apptData['reason'],
      status: 'scheduled',
    );
    
    await createAppointment(appointment);
  }

  // Lấy lịch hẹn trong ngày (Receptionist xem tất cả)
  Stream<QuerySnapshot> getTodayAppointments() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection('appointments')
        .where('appointment_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointment_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('appointment_date')
        .snapshots();
  }

  // Hành động: Bác sĩ khám xong, tạo test_orders (Status: PENDING)
  Future<String> initiateTestOrder(TestOrderModel order) async {
    // 1. Create the test order
    final orderRef = await _db.collection('test_orders').add(order.toFirestore());
    
    // 2. Update the appointment status to 'completed'
    await order.appointmentId.update({'status': 'completed'});
    
    return orderRef.id;
  }

  // Get current appointments for a doctor
  Stream<QuerySnapshot> getDoctorAppointments(String doctorUid) {
    return _db
        .collection('appointments')
        .where('doctor_id', isEqualTo: _db.doc('doctors/$doctorUid'))
        .where('status', isEqualTo: 'scheduled')
        .snapshots();
  }

  // Cập nhật trạng thái lịch hẹn
  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    await _db.collection('appointments').doc(appointmentId).update({'status': newStatus});
  }
}
