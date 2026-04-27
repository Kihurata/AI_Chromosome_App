import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sample.dart';

class SampleModel {
  final String id;
  final DocumentReference testOrderId;
  final DocumentReference collectedBy;
  final DateTime collectedAt;
  final String status;
  final String? notes;

  SampleModel({
    required this.id,
    required this.testOrderId,
    required this.collectedBy,
    required this.collectedAt,
    this.status = 'COLLECTED',
    this.notes,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'test_order_id': testOrderId,
      'collected_by': collectedBy,
      'collected_at': Timestamp.fromDate(collectedAt),
      'status': status,
      'notes': notes,
      'updated_at': Timestamp.fromDate(collectedAt),
    };
  }

  factory SampleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SampleModel(
      id: doc.id,
      testOrderId: data['test_order_id'] as DocumentReference,
      collectedBy: data['collected_by'] as DocumentReference,
      collectedAt: (data['collected_at'] as Timestamp).toDate(),
      status: data['status'] ?? 'COLLECTED',
      notes: data['notes'] as String?,
    );
  }

  factory SampleModel.fromEntity(Sample sample) {
    final firestore = FirebaseFirestore.instance;
    return SampleModel(
      id: sample.id,
      testOrderId:
          firestore.collection('test_orders').doc(sample.testOrderId),
      collectedBy: firestore.collection('users').doc(sample.collectedBy),
      collectedAt: sample.collectedAt,
      status: sample.status.toFirestoreString(),
      notes: sample.notes,
    );
  }
}
