import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getTodayAppointments();
  Future<List<AppointmentModel>> getAppointmentsInRange(DateTime start, DateTime end);
  Future<void> createAppointment(AppointmentModel appointment);
  Future<List<Map<String, dynamic>>> getClinicians();
}

class FirebaseAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createAppointment(AppointmentModel appointment) async {
    await _firestore.collection('appointments').add(appointment.toFirestore());
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsInRange(DateTime start, DateTime end) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('appointment_date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('appointment_date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('appointment_date')
        .get();
        
    return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<AppointmentModel>> getTodayAppointments() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection('appointments')
        .where('appointment_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointment_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('appointment_date')
        .get();
        
    return snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getClinicians() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', whereIn: ['clinician'])
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'full_name': data['full_name'] ?? '',
        'role': data['role'] ?? '',
      };
    }).toList();
  }
}
