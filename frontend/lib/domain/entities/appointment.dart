import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  scheduled,
  inProgress,
  completed,
  cancelled;

  static AppointmentStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return AppointmentStatus.inProgress;
      case 'COMPLETED':
        return AppointmentStatus.completed;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.scheduled;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'SCHEDULED';
      case AppointmentStatus.inProgress:
        return 'IN_PROGRESS';
      case AppointmentStatus.completed:
        return 'COMPLETED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Chờ khám';
      case AppointmentStatus.inProgress:
        return 'Đang khám';
      case AppointmentStatus.completed:
        return 'Hoàn tất';
      case AppointmentStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime appointmentDate;
  final AppointmentStatus status;
  final String reason;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    this.status = AppointmentStatus.scheduled,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        doctorId,
        doctorName,
        appointmentDate,
        status,
        reason,
      ];
}
