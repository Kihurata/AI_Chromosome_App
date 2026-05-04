import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sample_model.dart';

abstract class SampleRemoteDataSource {
  Future<void> createSample(SampleModel sample);
  Future<void> updateSampleStatus(String sampleId, String status);
}

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
}
