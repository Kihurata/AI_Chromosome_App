import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const bool isLoggedIn = false;
const String currentUserRole = '';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) return '/login';

      if (isLoggedIn && isGoingToLogin) {
        return _getInitialRouteForRole(currentUserRole);
      }

      if (isLoggedIn) {
        final path = state.matchedLocation;

        if (path.startsWith('/receptionist') &&
            currentUserRole != 'receptionist') {
          return _getInitialRouteForRole(currentUserRole);
        }

        if (path.startsWith('/clinician') && currentUserRole != 'clinician') {
          return _getInitialRouteForRole(currentUserRole);
        }

        if (path.startsWith('/specialist') && currentUserRole != 'specialist') {
          return _getInitialRouteForRole(currentUserRole);
        }

        if (path.startsWith('/manager') && currentUserRole != 'manager') {
          return _getInitialRouteForRole(currentUserRole);
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('LỖI: Bạn không có quyền vào đây!')),
        ),
      ),

      // --- KHU VỰC RECEPTIONIST ---
      GoRoute(
        path: '/receptionist/patients',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Danh sách Bệnh Nhân (Lễ Tân)')),
        ),
      ),

      // --- KHU VỰC CLINICIAN ---
      GoRoute(
        path: '/clinician/appointments',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Lịch Khám (Bác Sĩ)'))),
      ),

      // --- KHU VỰC SPECIALIST ---
      GoRoute(
        path: '/specialist/diagnoses',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Chẩn Đoán (Chuyên Gia)'))),
      ),

      // --- KHU VỰC MANAGER ---
      GoRoute(
        path: '/manager/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Dashboard (Quản Lý)'))),
      ),
    ],
  );

  static String _getInitialRouteForRole(String role) {
    switch (role) {
      case 'receptionist':
        return '/receptionist/patients';
      case 'clinician':
        return '/clinician/appointments';
      case 'specialist':
        return '/specialist/assigned-tests';
      case 'manager':
        return '/manager/lab-tests';
      default:
        return '/login';
    }
  }
}
