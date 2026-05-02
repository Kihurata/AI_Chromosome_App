import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/metaphase_image.dart';

class MetaphaseImageModel extends MetaphaseImage {
  const MetaphaseImageModel({
    required super.id,
    required super.orderId,
    required super.rawImageUrl,
    super.status,
    super.processingTimeMs,
    required super.createdAt,
  });

  factory MetaphaseImageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MetaphaseImageModel(
      id: doc.id,
      orderId: data['order_id'] ?? '',
      rawImageUrl: data['raw_image_url'] ?? '',
      status: AiProcessingStatus.fromString(data['status'] ?? 'UPLOADED'),
      processingTimeMs: data['processing_time_ms'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MetaphaseImageModel.fromEntity(MetaphaseImage entity) {
    return MetaphaseImageModel(
      id: entity.id,
      orderId: entity.orderId,
      rawImageUrl: entity.rawImageUrl,
      status: entity.status,
      processingTimeMs: entity.processingTimeMs,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'order_id': orderId,
      'raw_image_url': rawImageUrl,
      'status': status.toFirestoreString(),
      'processing_time_ms': processingTimeMs,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
