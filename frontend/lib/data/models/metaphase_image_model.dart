import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/metaphase_image.dart';

class MetaphaseImageModel extends MetaphaseImage {
  const MetaphaseImageModel({
    required super.id,
    required super.orderId,
    required super.rawImageUrl,
    super.aiImageUrl,
    super.status,
    super.processingTimeMs,
    super.aiCount,
    super.aiScore,
    required super.createdAt,
  });

  factory MetaphaseImageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MetaphaseImageModel(
      id: doc.id,
      orderId: data['order_id'] ?? '',
      rawImageUrl: data['raw_image_url'] ?? '',
      aiImageUrl: data['ai_image_url'],
      status: AiProcessingStatus.fromString(data['status'] ?? 'UPLOADED'),
      processingTimeMs: data['processing_time_ms'],
      aiCount: data['ai_count'],
      aiScore: data['ai_score'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MetaphaseImageModel.fromEntity(MetaphaseImage entity) {
    return MetaphaseImageModel(
      id: entity.id,
      orderId: entity.orderId,
      rawImageUrl: entity.rawImageUrl,
      aiImageUrl: entity.aiImageUrl,
      status: entity.status,
      processingTimeMs: entity.processingTimeMs,
      aiCount: entity.aiCount,
      aiScore: entity.aiScore,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'order_id': orderId,
      'raw_image_url': rawImageUrl,
      'ai_image_url': aiImageUrl,
      'status': status.toFirestoreString(),
      'processing_time_ms': processingTimeMs,
      'ai_count': aiCount,
      'ai_score': aiScore,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
