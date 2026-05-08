import 'package:equatable/equatable.dart';

enum AiProcessingStatus {
  uploading,
  uploaded,
  processing,
  completed,
  failed;

  static AiProcessingStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'UPLOADING': // local state only
        return AiProcessingStatus.uploading;
      case 'UPLOADED':
        return AiProcessingStatus.uploaded;
      case 'PROCESSING':
        return AiProcessingStatus.processing;
      case 'COMPLETED':
        return AiProcessingStatus.completed;
      case 'FAILED':
        return AiProcessingStatus.failed;
      default:
        return AiProcessingStatus.uploaded;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case AiProcessingStatus.uploading:
        return 'UPLOADED'; // fallback for db
      case AiProcessingStatus.uploaded:
        return 'UPLOADED';
      case AiProcessingStatus.processing:
        return 'PROCESSING';
      case AiProcessingStatus.completed:
        return 'COMPLETED';
      case AiProcessingStatus.failed:
        return 'FAILED';
    }
  }
}

class DiagnosisSuggestion extends Equatable {
  final String iscn;
  final String description;
  final double confidence;

  const DiagnosisSuggestion({
    required this.iscn,
    required this.description,
    required this.confidence,
  });

  @override
  List<Object?> get props => [iscn, description, confidence];
}

class MetaphaseImage extends Equatable {
  final String id;
  final String orderId;
  final String rawImageUrl;
  final String? aiImageUrl;
  final AiProcessingStatus status;
  final int? processingTimeMs;
  final int? aiCount;
  final int? aiScore;
  final double? aiConfidence;
  final List<DiagnosisSuggestion> aiSuggestions;
  final DateTime createdAt;

  const MetaphaseImage({
    required this.id,
    required this.orderId,
    required this.rawImageUrl,
    this.aiImageUrl,
    this.status = AiProcessingStatus.uploaded,
    this.processingTimeMs,
    this.aiCount,
    this.aiScore,
    this.aiConfidence,
    this.aiSuggestions = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        rawImageUrl,
        aiImageUrl,
        status,
        processingTimeMs,
        aiCount,
        aiScore,
        aiConfidence,
        aiSuggestions,
        createdAt,
      ];
}
