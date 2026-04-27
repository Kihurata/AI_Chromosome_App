import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_order_model.dart';

abstract class TestOrderRemoteDataSource {
  Future<void> createTestOrder(TestOrderModel testOrder);
  Future<List<TestOrderModel>> getTestOrdersByClinician(String clinicianId);
}

class FirebaseTestOrderRemoteDataSource implements TestOrderRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createTestOrder(TestOrderModel testOrder) async {
    await _firestore
        .collection('test_orders')
        .add(testOrder.toFirestore());
  }

  @override
  Future<List<TestOrderModel>> getTestOrdersByClinician(
    String clinicianId,
  ) async {
    final clinicianRef =
        _firestore.collection('users').doc(clinicianId);

    final snapshot = await _firestore
        .collection('test_orders')
        .where('collected_by', isEqualTo: clinicianRef)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TestOrderModel.fromFirestore(doc))
        .toList();
  }
}
