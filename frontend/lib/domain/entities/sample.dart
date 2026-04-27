import 'package:equatable/equatable.dart';

enum SampleStatus {
  collected,
  inTransit,
  receivedByLab,
  processing,
  completed,
  failed;

  static SampleStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IN_TRANSIT':
        return SampleStatus.inTransit;
      case 'RECEIVED_BY_LAB':
        return SampleStatus.receivedByLab;
      case 'PROCESSING':
        return SampleStatus.processing;
      case 'COMPLETED':
        return SampleStatus.completed;
      case 'FAILED':
        return SampleStatus.failed;
      default:
        return SampleStatus.collected;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case SampleStatus.collected:
        return 'COLLECTED';
      case SampleStatus.inTransit:
        return 'IN_TRANSIT';
      case SampleStatus.receivedByLab:
        return 'RECEIVED_BY_LAB';
      case SampleStatus.processing:
        return 'PROCESSING';
      case SampleStatus.completed:
        return 'COMPLETED';
      case SampleStatus.failed:
        return 'FAILED';
    }
  }
}

class Sample extends Equatable {
  final String id;
  final String testOrderId;
  final String collectedBy;
  final DateTime collectedAt;
  final SampleStatus status;
  final String? notes;

  const Sample({
    required this.id,
    required this.testOrderId,
    required this.collectedBy,
    required this.collectedAt,
    this.status = SampleStatus.collected,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        testOrderId,
        collectedBy,
        collectedAt,
        status,
        notes,
      ];
}
