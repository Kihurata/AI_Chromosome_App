import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/sample_model.dart';

abstract class SampleRemoteDataSource {
  Future<void> createSample(SampleModel sample);
  Future<void> updateSampleStatus(String sampleId, String status);
  Stream<List<SampleModel>> watchSamples();
  Stream<List<SampleModel>> watchSamplesByStatus(String status);
  Future<SampleModel> getSampleById(String id);
  Future<void> updateSampleNote(String id, String note);
}

@LazySingleton(as: SampleRemoteDataSource)
class FirebaseSampleRemoteDataSource implements SampleRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createSample(SampleModel sample) async {
    await _firestore.collection('samples').doc(sample.id).set(sample.toFirestore());
  }

  @override
  Future<void> updateSampleStatus(String sampleId, String status) async {
    await _firestore.collection('samples').doc(sampleId).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<SampleModel> getSampleById(String id) async {
    // id is the TestOrder document ID. samples.test_order_id is a Firestore Reference.
    final orderRef = _firestore.doc('test_orders/$id');
    final querySnapshot = await _firestore
        .collection('samples')
        .where('test_order_id', isEqualTo: orderRef)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) throw Exception('Sample not found');
    return SampleModel.fromFirestore(querySnapshot.docs.first);
  }

  @override
  Future<void> updateSampleNote(String id, String note) async {
    await _firestore.collection('samples').doc(id).update({
      'notes': note,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<SampleModel>> watchSamples() {
    return _firestore
        .collection('samples')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SampleModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<SampleModel>> watchSamplesByStatus(String status) {
    return _firestore
        .collection('samples')
        .where('status', isEqualTo: status)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SampleModel.fromFirestore(doc))
            .toList());
  }
}
