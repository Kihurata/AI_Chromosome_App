import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/test_order_model.dart';

abstract class TestOrderRemoteDataSource {
  Future<void> createTestOrder(TestOrderModel testOrder);
  Future<List<TestOrderModel>> getTestOrdersByClinician(String clinicianId);
  Future<List<TestOrderModel>> getAllPendingOrders();
  Future<void> updateOrderStatus(String orderId, String status, {String? reason});
  Future<void> assignSpecialistToOrder(String orderId, String specialistId);
  Stream<List<TestOrderModel>> watchAssignedOrders(String specialistId);
  Stream<List<TestOrderModel>> watchAllOrders();
  Stream<List<TestOrderModel>> watchTestOrdersByPatient(String patientId);
  Future<List<TestOrderModel>> getTestOrdersByPatient(String patientId);
  Future<void> updateOrderSpecialist(String orderId, String specialistId);
}

@Injectable(as: TestOrderRemoteDataSource)
class FirebaseTestOrderRemoteDataSource implements TestOrderRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createTestOrder(TestOrderModel testOrder) async {
    await _firestore.collection('test_orders').doc(testOrder.id).set(testOrder.toFirestore());
  }

  @override
  Future<List<TestOrderModel>> getTestOrdersByClinician(
    String clinicianId,
  ) async {
    final clinicianRef = _firestore.collection('users').doc(clinicianId);

    final snapshot = await _firestore
        .collection('test_orders')
        .where('collected_by', isEqualTo: clinicianRef)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TestOrderModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<TestOrderModel>> getAllPendingOrders() async {
    final snapshot = await _firestore
        .collection('test_orders')
        .where('status', isEqualTo: 'PENDING')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TestOrderModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status, {String? reason}) async {
    await _firestore.collection('test_orders').doc(orderId).update({
      'status': status,
      'rejection_reason': reason,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> assignSpecialistToOrder(
    String orderId,
    String specialistId,
  ) async {
    final specialistRef = _firestore.collection('users').doc(specialistId);
    await _firestore.collection('test_orders').doc(orderId).update({
      'specialist_id': specialistRef,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<TestOrderModel>> watchAssignedOrders(String specialistId) {
    final specialistRef = _firestore.collection('users').doc(specialistId);
    return _firestore
        .collection('test_orders')
        .where('specialist_id', isEqualTo: specialistRef)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TestOrderModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<TestOrderModel>> watchAllOrders() {
    return _firestore
        .collection('test_orders')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TestOrderModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Stream<List<TestOrderModel>> watchTestOrdersByPatient(String patientId) {
    final patientRef = _firestore.collection('patients').doc(patientId);
    return _firestore
        .collection('test_orders')
        .where('patient_id', isEqualTo: patientRef)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TestOrderModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<List<TestOrderModel>> getTestOrdersByPatient(String patientId) async {
    final patientRef = _firestore.collection('patients').doc(patientId);
    final snapshot = await _firestore
        .collection('test_orders')
        .where('patient_id', isEqualTo: patientRef)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TestOrderModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> updateOrderSpecialist(String orderId, String specialistId) async {
    final specialistRef = _firestore.collection('users').doc(specialistId);
    await _firestore.collection('test_orders').doc(orderId).update({
      'specialist_id': specialistRef,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
