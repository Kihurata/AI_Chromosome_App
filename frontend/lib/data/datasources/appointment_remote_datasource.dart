import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getTodayAppointments();
  Stream<List<AppointmentModel>> watchTodayAppointments();
  Future<List<AppointmentModel>> getAppointmentsInRange(DateTime start, DateTime end);
  Future<void> createAppointment(AppointmentModel appointment);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
}

@LazySingleton(as: AppointmentRemoteDataSource)
class FirebaseAppointmentRemoteDataSource implements AppointmentRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseAppointmentRemoteDataSource(this._firestore);

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
  Stream<List<AppointmentModel>> watchTodayAppointments() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('appointments')
        .where('appointment_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('appointment_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('appointment_date')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': status});
  }

  Future<String?> getAppointmentIdByDocId(String docId) async {
    return docId;
  }
}
