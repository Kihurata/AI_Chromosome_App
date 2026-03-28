import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/test_order_model.dart';
import '../models/patient_model.dart';

class ClinicalRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────────────────────────────────────────────────
  // Patient CRUD
  // ────────────────────────────────────────────────────

  Future<String> createPatient(PatientModel patient) async {
    final docRef = await _db.collection('patients').add(patient.toFirestore());

    // Auto-generate patient_code: BN-000001
    final code = 'BN-${docRef.id.substring(0, 6).toUpperCase()}';
    await docRef.update({'patient_code': code});

    return docRef.id;
  }

  Stream<List<PatientModel>> getAllPatients() {
    return _db
        .collection('patients')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PatientModel.fromFirestore(doc)).toList());
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    if (query.isEmpty) return [];

    final queryUpper = query.toUpperCase();

    // Search by phone or identity_card or name
    final snapshot = await _db.collection('patients').get();

    return snapshot.docs
        .map((doc) => PatientModel.fromFirestore(doc))
        .where((p) =>
            p.fullName.toUpperCase().contains(queryUpper) ||
            p.phone.contains(query) ||
            p.identityCard.contains(query) ||
            (p.patientCode ?? '').toUpperCase().contains(queryUpper))
        .toList();
  }

  /// Check if a patient with the same identity_card or phone already exists
  Future<PatientModel?> checkDuplicatePatient({
    String? identityCard,
    String? phone,
  }) async {
    // Check by identity_card first (most reliable)
    if (identityCard != null && identityCard.isNotEmpty) {
      final snapshot = await _db
          .collection('patients')
          .where('identity_card', isEqualTo: identityCard)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return PatientModel.fromFirestore(snapshot.docs.first);
      }
    }

    // Check by phone
    if (phone != null && phone.isNotEmpty) {
      final snapshot = await _db
          .collection('patients')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return PatientModel.fromFirestore(snapshot.docs.first);
      }
    }

    return null;
  }

  // ────────────────────────────────────────────────────
  // Appointments
  // ────────────────────────────────────────────────────

  Future<String> createAppointment(AppointmentModel appointment) async {
    final docRef = await _db.collection('appointments').add(appointment.toFirestore());
    return docRef.id;
  }

  Future<void> registerPatientWithAppointment(PatientModel patient, Map<String, dynamic> apptData) async {
    final patientIdStr = await createPatient(patient);
    final patientRef = _db.doc('patients/$patientIdStr');

    final appointment = AppointmentModel(
      id: '',
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

  /// Get appointments for a date range (for Calendar view)
  Stream<QuerySnapshot> getAppointmentsInRange(DateTime start, DateTime end) {
    return _db
        .collection('appointments')
        .where('appointment_date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('appointment_date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('appointment_date')
        .snapshots();
  }

  /// Get all clinician doctors for assigning appointments
  Future<List<Map<String, dynamic>>> getClinicians() async {
    final usersSnapshot = await _db
        .collection('users')
        .where('role', whereIn: ['clinician', 'specialist'])
        .where('status', isEqualTo: 'active')
        .get();

    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'full_name': data['full_name'] ?? '',
        'role': data['role'] ?? '',
      };
    }).toList();
  }

  Future<String> initiateTestOrder(TestOrderModel order) async {
    final orderRef = await _db.collection('test_orders').add(order.toFirestore());
    await order.appointmentId.update({'status': 'completed'});
    return orderRef.id;
  }

  Stream<QuerySnapshot> getDoctorAppointments(String doctorUid) {
    return _db
        .collection('appointments')
        .where('doctor_id', isEqualTo: _db.doc('doctors/$doctorUid'))
        .where('status', isEqualTo: 'scheduled')
        .snapshots();
  }

  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    await _db.collection('appointments').doc(appointmentId).update({'status': newStatus});
  }
}
