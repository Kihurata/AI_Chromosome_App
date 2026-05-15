import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _onMessageSubscription;

  // Internal session list maintained independently of state for persistence
  final List<NotificationItem> _sessionNotifications = [];
  int _unreadCount = 0;

  NotificationCubit() : super(const NotificationListState());

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Listen to Auth Changes to update token
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          try {
            String? token = await _fcm.getToken();
            if (token != null) {
              debugPrint("FCM Token: $token");
              await _updateUserToken(token, user.uid);
            }
          } catch (e) {
            debugPrint("Error getting FCM token: $e");
          }
        }
      });

      // 3. Listen to Foreground Messages
      _onMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(message);
      });
    }
  }

  Future<void> _updateUserToken(String token, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcm_token': token});
      debugPrint("Successfully updated FCM token in Firestore for user: $uid");
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        // Document doesn't exist yet — skip silently to avoid partial writes
        // that would reset the user's role to the fallback (Receptionist).
        debugPrint("NotificationCubit: User doc not found for $uid. Skipping FCM token update.");
      } else {
        debugPrint("NotificationCubit: FirebaseException updating FCM token: ${e.code} - ${e.message}");
      }
    } catch (e) {
      debugPrint("NotificationCubit: Error updating FCM token in Firestore: $e");
    }
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    // Use notification title/body OR fallback to data title/body (for data-only messages)
    final String title = notification?.title ?? data['title'] ?? "Thông báo";
    final String body = notification?.body ?? data['body'] ?? "";
    final String type = data['type'] ?? 'DEFAULT';

    if (title.isNotEmpty) {
      // Append to session list
      final item = NotificationItem(
        title: title,
        body: body,
        type: type,
        relatedId: data['relatedId'],
        receivedAt: DateTime.now(),
      );
      _sessionNotifications.insert(0, item); // newest first
      _unreadCount++;

      // Play Sound
      _playSound(type);

      // 1. Emit one-shot trigger for Snackbar/BlocListener in main.dart
      emit(NotificationReceived(
        title: title,
        body: body,
        type: type,
        relatedId: data['relatedId'],
      ));

      // 2. Immediately restore list state so bell badge updates
      _emitListState();
    }
  }

  /// Call this when the user opens the notification panel to clear unread count.
  void markAllRead() {
    _unreadCount = 0;
    _emitListState();
  }

  void _emitListState() {
    if (isClosed) return;
    emit(NotificationListState(
      notifications: List.unmodifiable(_sessionNotifications),
      unreadCount: _unreadCount,
    ));
  }

  void _playSound(String type) async {
    String soundAsset = 'sounds/info.wav'; // Default

    switch (type) {
      case 'ORDER_COMPLETED':
        soundAsset = 'sounds/success.wav';
        break;
      case 'ORDER_REJECTED':
        soundAsset = 'sounds/error.wav';
        break;
      case 'ORDER_PENDING':
      case 'ANALYSIS_READY':
        soundAsset = 'sounds/warning.wav';
        break;
      case 'ORDER_ASSIGNED':
        soundAsset = 'sounds/info.wav';
        break;
    }

    try {
      await _audioPlayer.play(AssetSource(soundAsset));
    } catch (e) {
      debugPrint("Audio play failed: $e. Make sure assets/sounds/$soundAsset exists.");
    }
  }

  void onActionPressed(String relatedId, String type) {
    emit(NotificationActionRequested(relatedId: relatedId, type: type));
    // Immediately return to list state to allow same action to be triggered again
    _emitListState();
  }

  @override
  Future<void> close() {
    _onMessageSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
