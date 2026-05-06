part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationReceived extends NotificationState {
  final String title;
  final String body;
  final String type;
  final String? relatedId;

  const NotificationReceived({
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
  });

  @override
  List<Object?> get props => [title, body, type, relatedId];
}

class NotificationActionRequested extends NotificationState {
  final String relatedId;
  final String type;

  const NotificationActionRequested({
    required this.relatedId,
    required this.type,
  });

  @override
  List<Object?> get props => [relatedId, type];
}
