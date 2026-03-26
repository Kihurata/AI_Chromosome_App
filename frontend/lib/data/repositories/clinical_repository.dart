import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/test_order_model.dart';

class ClinicalRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Giai đoạn 1: Đặt lịch & Thăm khám (Clinical Stage)
  
  // Hành động: Tạo appointment mới
  Future<String> createAppointment(AppointmentModel appointment) async {
    final docRef = await _db.collection('appointments').add(appointment.toFirestore());
    return docRef.id;
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
}
