import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_factory.dart';
import 'package:injectable/injectable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  final String role;
  Authenticated(this.user, this.role);
}
class Unauthenticated extends AuthState {}

/// Legacy error state — kept for backward compatibility.
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// Enhanced error state that carries a [NotificationType] so the
/// Presentation layer can dispatch to [NotificationFactory].
class AuthErrorWithType extends AuthState {
  final String message;
  final NotificationType type;
  final VoidCallbackAction? retryAction;

  AuthErrorWithType(this.message, this.type, {this.retryAction});
}

/// Callback type for retry actions.
typedef VoidCallbackAction = void Function();

@injectable
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Store last login credentials for retry functionality
  String? _lastEmail;
  String? _lastPassword;

  AuthCubit() : super(AuthInitial()) {
    _authService.userStream.listen((user) async {
      if (user != null) {
        try {
          // Fetch role from Firestore
          print("AuthCubit: Project ID: ${_db.app.options.projectId}");
          print("AuthCubit: Fetching role for ${user.uid}");
          // Force fetch from server to avoid stale cache on F5
          final doc = await _db.collection('users').doc(user.uid).get(const GetOptions(source: Source.server));
          if (doc.exists) {
            print("AuthCubit: Document data: ${doc.data()}");
            final role = doc.data()?['role'] ?? 'user';
            print("AuthCubit: Role fetched: '$role'");
            emit(Authenticated(user, role));
          } else {
            // No profile found, logout and error
            await _authService.signOut();
            emit(AuthErrorWithType(
              "Tài khoản chưa được gán hồ sơ nhân viên.",
              NotificationType.error,
            ));
          }
        } catch (e) {
          if (_isNetworkError(e)) {
            emit(AuthErrorWithType(
              "Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.",
              NotificationType.errorRetry,
            ));
          } else {
            emit(AuthErrorWithType(
              "Lỗi kết nối dữ liệu người dùng.",
              NotificationType.error,
            ));
          }
        }
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> login(String email, String password) async {
    _lastEmail = email;
    _lastPassword = password;
    emit(AuthLoading());
    try {
      final userCreds = await _authService.signInWithEmail(email, password);
      // Wait for the stream to update the state
      if (userCreds?.user == null) {
        emit(AuthErrorWithType(
          "Đăng nhập thất bại. Vui lòng thử lại.",
          NotificationType.error,
        ));
      }
    } on FirebaseAuthException catch (e) {
      final mapped = _mapFirebaseAuthError(e.code);
      emit(AuthErrorWithType(mapped.$1, mapped.$2));
    } catch (e) {
      if (_isNetworkError(e)) {
        emit(AuthErrorWithType(
          "Không có kết nối mạng. Vui lòng kiểm tra Internet và thử lại.",
          NotificationType.errorRetry,
        ));
      } else {
        emit(AuthErrorWithType(
          "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.",
          NotificationType.errorRetry,
        ));
      }
    }
  }

  /// Retry the last login attempt (used by NotificationFactory retry dialog).
  void retryLogin() {
    if (_lastEmail != null && _lastPassword != null) {
      login(_lastEmail!, _lastPassword!);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    emit(Unauthenticated());
  }

  // ──────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────

  /// Maps Firebase Auth error codes to user-friendly Vietnamese messages
  /// and the appropriate [NotificationType].
  (String, NotificationType) _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return ("Email không tồn tại trong hệ thống.", NotificationType.validationError);
      case 'wrong-password':
        return ("Sai mật khẩu. Vui lòng nhập lại.", NotificationType.validationError);
      case 'invalid-credential':
        return ("Email hoặc mật khẩu không chính xác.", NotificationType.validationError);
      case 'invalid-email':
        return ("Địa chỉ Email không hợp lệ.", NotificationType.validationError);
      case 'user-disabled':
        return ("Tài khoản đã bị vô hiệu hóa. Liên hệ Admin.", NotificationType.error);
      case 'too-many-requests':
        return ("Quá nhiều lần thử. Vui lòng đợi vài phút.", NotificationType.warning);
      case 'network-request-failed':
        return ("Không có kết nối mạng. Vui lòng kiểm tra Internet.", NotificationType.errorRetry);
      default:
        return ("Đã xảy ra lỗi xác thực. Mã lỗi: $code", NotificationType.error);
    }
  }

  /// Detects network-related exceptions.
  bool _isNetworkError(Object error) {
    if (error is SocketException) return true;
    final msg = error.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('timeout') ||
        msg.contains('host lookup');
  }
}

