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

  NotificationCubit() : super(NotificationInitial());

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
          .set({'fcm_token': token}, SetOptions(merge: true));
      debugPrint("Successfully updated FCM token in Firestore for user: $uid");
    } catch (e) {
      debugPrint("Error updating user token in Firestore: $e");
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
      // Play Sound
      _playSound(type);

      emit(NotificationReceived(
        title: title,
        body: body,
        type: type,
        relatedId: data['relatedId'],
      ));
      
      emit(NotificationInitial());
    }
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
    // Immediately return to initial to allow same action to be triggered again if needed
    emit(NotificationInitial());
  }

  @override
  Future<void> close() {
    _onMessageSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
