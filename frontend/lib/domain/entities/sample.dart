import 'package:equatable/equatable.dart';

enum SampleStatus {
  collected,
  culturing,
  harvested,
  failed;

  static SampleStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'COLLECTED':
        return SampleStatus.collected;
      case 'CULTURING':
        return SampleStatus.culturing;
      case 'HARVESTED':
        return SampleStatus.harvested;
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
      case SampleStatus.culturing:
        return 'CULTURING';
      case SampleStatus.harvested:
        return 'HARVESTED';
      case SampleStatus.failed:
        return 'FAILED';
    }
  }
}

class Sample extends Equatable {
  final String id;
  final String testOrderId;
  final String patientName;
  final String patientCode;
  final String sampleType;
  final String collectedBy;
  final DateTime collectedAt;
  final SampleStatus status;
  final String? notes;

  const Sample({
    required this.id,
    required this.testOrderId,
    required this.patientName,
    required this.patientCode,
    required this.sampleType,
    required this.collectedBy,
    required this.collectedAt,
    this.status = SampleStatus.collected,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        testOrderId,
        patientName,
        patientCode,
        sampleType,
        collectedBy,
        collectedAt,
        status,
        notes,
      ];
}
