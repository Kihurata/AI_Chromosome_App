import 'package:equatable/equatable.dart';

enum TestOrderStatus {
  pending,
  culturing,
  analyzing,
  waitingApproval,
  completed,
  rejected;

  static TestOrderStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CULTURING':
        return TestOrderStatus.culturing;
      case 'ANALYZING':
        return TestOrderStatus.analyzing;
      case 'WAITING_APPROVAL':
        return TestOrderStatus.waitingApproval;
      case 'COMPLETED':
        return TestOrderStatus.completed;
      case 'REJECTED':
        return TestOrderStatus.rejected;
      case 'IN_PROGRESS': // Compatibility
        return TestOrderStatus.analyzing;
      case 'WAITING_FOR_APPROVAL': // Compatibility
        return TestOrderStatus.waitingApproval;
      default:
        return TestOrderStatus.pending;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case TestOrderStatus.pending:
        return 'PENDING';
      case TestOrderStatus.culturing:
        return 'CULTURING';
      case TestOrderStatus.analyzing:
        return 'ANALYZING';
      case TestOrderStatus.waitingApproval:
        return 'WAITING_APPROVAL';
      case TestOrderStatus.completed:
        return 'COMPLETED';
      case TestOrderStatus.rejected:
        return 'REJECTED';
    }
  }

  String get displayName {
    switch (this) {
      case TestOrderStatus.pending:
        return 'Chờ xử lý';
      case TestOrderStatus.culturing:
        return 'Đang nuôi cấy';
      case TestOrderStatus.analyzing:
        return 'Đang phân tích';
      case TestOrderStatus.waitingApproval:
        return 'Chờ duyệt';
      case TestOrderStatus.completed:
        return 'Hoàn thành';
      case TestOrderStatus.rejected:
        return 'Bị từ chối';
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
