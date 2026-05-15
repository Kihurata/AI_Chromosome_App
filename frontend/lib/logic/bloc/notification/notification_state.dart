part of 'notification_cubit.dart';

// --- Abstract base state ---
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

// --- Data model for a single notification item ---
class NotificationItem extends Equatable {
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final DateTime receivedAt;

  const NotificationItem({
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.receivedAt,
  });

  @override
  List<Object?> get props => [title, body, type, relatedId, receivedAt];
}

// --- Persistent state: holds the accumulated session list ---
class NotificationListState extends NotificationState {
  final List<NotificationItem> notifications;
  final int unreadCount;

  const NotificationListState({
    this.notifications = const [],
    this.unreadCount = 0,
  });

  NotificationListState copyWith({
    List<NotificationItem>? notifications,
    int? unreadCount,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount];
}

// --- One-shot trigger for Snackbar / Sound (emitted momentarily) ---
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
