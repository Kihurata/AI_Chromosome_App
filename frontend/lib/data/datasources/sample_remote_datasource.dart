import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/sample_model.dart';

abstract class SampleRemoteDataSource {
  Future<void> createSample(SampleModel sample);
  Future<void> updateSampleStatus(String sampleId, String status);
  Stream<List<SampleModel>> watchSamples();
  Stream<List<SampleModel>> watchSamplesByStatus(String status);
}

@LazySingleton(as: SampleRemoteDataSource)
class FirebaseSampleRemoteDataSource implements SampleRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createSample(SampleModel sample) async {
    await _firestore.collection('samples').add(sample.toFirestore());
  }

  @override
  Future<void> updateSampleStatus(String sampleId, String status) async {
    await _firestore.collection('samples').doc(sampleId).update({
      'status': status,
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
