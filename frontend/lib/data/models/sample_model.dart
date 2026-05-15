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
    super.expectedHarvestTime,
    super.actualHarvestTime,
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
      if (expectedHarvestTime != null) 'expected_harvest_time': Timestamp.fromDate(expectedHarvestTime!),
      if (actualHarvestTime != null) 'actual_harvest_time': Timestamp.fromDate(actualHarvestTime!),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  factory SampleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Helper function to safely extract ID from Reference or String
    String extractId(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      if (value is DocumentReference) return value.id;
      return value.toString();
    }

    return SampleModel(
      id: doc.id,
      testOrderId: extractId(data['test_order_id'], ''),
      patientName: data['patient_name'] ?? '',
      patientCode: data['patient_code'] ?? '',
      sampleType: data['sample_type'] ?? '',
      collectedBy: extractId(data['collected_by'], 'SYSTEM'),
      collectedAt: data['collected_at'] != null
          ? (data['collected_at'] as Timestamp).toDate()
          : (data['collection_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: SampleStatus.fromString(data['status'] ?? 'COLLECTED'),
      notes: data['notes'] as String?,
      expectedHarvestTime: data['expected_harvest_time'] != null
          ? (data['expected_harvest_time'] as Timestamp).toDate()
          : null,
      actualHarvestTime: data['actual_harvest_time'] != null
          ? (data['actual_harvest_time'] as Timestamp).toDate()
          : null,
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
      expectedHarvestTime: sample.expectedHarvestTime,
      actualHarvestTime: sample.actualHarvestTime,
    );
  }
}
