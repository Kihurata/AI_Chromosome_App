import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sample.dart';

class SampleModel extends Sample {
  const SampleModel({
    required super.id,
    required super.testOrderId,
    required super.patientName,
    required super.patientCode,
    required super.sampleType,
    required super.collectedBy,
    required super.collectedAt,
    super.status,
    super.notes,
  });

  Map<String, dynamic> toFirestore() {
    final firestore = FirebaseFirestore.instance;
    return {
      'id': id,
      'test_order_id': firestore.collection('test_orders').doc(testOrderId),
      'patient_name': patientName,
      'patient_code': patientCode,
      'sample_type': sampleType,
      'collected_by': firestore.collection('users').doc(collectedBy),
      'collected_at': Timestamp.fromDate(collectedAt),
      'status': status.toFirestoreString(),
      'notes': notes,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory SampleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SampleModel(
      id: doc.id,
      testOrderId: data['test_order_id'] != null
          ? (data['test_order_id'] as DocumentReference).id
          : '',
      patientName: data['patient_name'] ?? '',
      patientCode: data['patient_code'] ?? '',
      sampleType: data['sample_type'] ?? '',
      collectedBy: data['collected_by'] != null
          ? (data['collected_by'] as DocumentReference).id
          : 'SYSTEM',
      collectedAt: data['collected_at'] != null
          ? (data['collected_at'] as Timestamp).toDate()
          : (data['collection_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: SampleStatus.fromString(data['status'] ?? 'COLLECTED'),
      notes: data['notes'] as String?,
    );
  }

  factory SampleModel.fromEntity(Sample sample) {
    return SampleModel(
      id: sample.id,
      testOrderId: sample.testOrderId,
      patientName: sample.patientName,
      patientCode: sample.patientCode,
      sampleType: sample.sampleType,
      collectedBy: sample.collectedBy,
      collectedAt: sample.collectedAt,
      status: sample.status,
      notes: sample.notes,
    );
  }
}
