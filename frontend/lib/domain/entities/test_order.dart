import 'package:equatable/equatable.dart';

enum TestOrderStatus {
  pending,
  inProgress,
  completed,
  rejected;

  static TestOrderStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return TestOrderStatus.inProgress;
      case 'COMPLETED':
        return TestOrderStatus.completed;
      case 'REJECTED':
        return TestOrderStatus.rejected;
      default:
        return TestOrderStatus.pending;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case TestOrderStatus.pending:
        return 'PENDING';
      case TestOrderStatus.inProgress:
        return 'IN_PROGRESS';
      case TestOrderStatus.completed:
        return 'COMPLETED';
      case TestOrderStatus.rejected:
        return 'REJECTED';
    }
  }
}

class TestOrder extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String patientCode;
  final String appointmentId;
  final String? specialistId;
  final TestOrderStatus status;
  final DateTime createdAt;

  const TestOrder({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientCode,
    required this.appointmentId,
    this.specialistId,
    this.status = TestOrderStatus.pending,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        patientCode,
        appointmentId,
        specialistId,
        status,
        createdAt,
      ];
}
