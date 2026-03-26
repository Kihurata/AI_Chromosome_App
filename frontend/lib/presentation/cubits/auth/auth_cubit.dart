import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

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
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial()) {
    _authService.userStream.listen((user) async {
      if (user != null) {
        try {
          // Fetch role from Firestore
          final doc = await _db.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final role = doc.data()?['role'] ?? 'user';
            emit(Authenticated(user, role));
          } else {
            // No profile found, logout and error
            await _authService.signOut();
            emit(AuthError("Tài khoản chưa được gán hồ sơ Bác sĩ."));
          }
        } catch (e) {
          emit(AuthError("Lỗi kết nối dữ liệu người dùng."));
        }
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final userCreds = await _authService.signInWithEmail(email, password);
      // Wait for the stream to update the state
      if (userCreds?.user == null) {
        emit(AuthError("Login failed: User is null"));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Đã xảy ra lỗi!";
      if (e.code == 'user-not-found') {
        errorMessage = "Email không tồn tại.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Sai mật khẩu.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Email không hợp lệ.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "Tài khoản bị vô hiệu hóa.";
      }
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    emit(Unauthenticated());
  }
}
