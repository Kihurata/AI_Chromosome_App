import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/nav_item.dart';
import '../config/app_nav_items.dart';
import '../providers/auth_provider.dart';
import '../../presentation/screens/auth/login_page.dart';
import '../../presentation/screens/receptionist/receptionist_dashboard_body.dart';
import '../../presentation/screens/receptionist/patient_list_page.dart';
import '../../presentation/screens/receptionist/appointment_calendar_page.dart';
import '../../presentation/screens/dashboard/doctor_dashboard_page.dart';
import '../../presentation/widgets/shared/app_navigation_wrapper.dart';

// ── Route path constants ──────────────────────────────────────────────────────
class AppRoutes {
  static const login = '/login';

  // Receptionist
  static const receptionistDashboard = '/receptionist/dashboard';
  static const receptionistPatients = '/receptionist/patients';
  static const receptionistAppointments = '/receptionist/appointments';

  // Clinician
  static const clinicianDashboard = '/clinician/dashboard';
  static const clinicianPatients = '/clinician/patients';
  static const clinicianLab = '/clinician/lab';

  // Specialist
  static const specialistDashboard = '/specialist/dashboard';
  static const specialistAnalysis = '/specialist/analysis';

  // Manager
  static const managerReports = '/manager/reports';
  static const managerStaff = '/manager/staff';

  // Shared
  static const profile = '/profile';
  static const forbidden = '/403';
}

// ── GoRouter Provider ─────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    refreshListenable: _AuthStateListenable(ref),

    // ── GLOBAL REDIRECT (Role-based Security) ────────────────────────────────
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final role = authState.role;

      // 1. Still loading — hold at current location (let splash handle it)
      if (isLoading) return null;

      // 2. Not authenticated — only allow login page
      if (!isAuthenticated) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }

      // 3. Authenticated user trying to visit login → redirect home
      if (location == AppRoutes.login || location == '/') {
        return role != null ? defaultRouteForRole(role) : AppRoutes.login;
      }

      // 4. Role-based access control
      // Find if this route is a known protected route in the nav config
      if (role != null) {
        final matchedNavItem = appNavItems.firstWhere(
          (item) => location.startsWith(item.routePath),
          orElse: () => NavItem(
            label: '',
            icon: Icons.error,
            routePath: location,
            allowedRoles: AppRole.values, // unknown routes: allow (not a nav route)
          ),
        );

        // If all roles are allowed (placeholder), skip role check
        if (matchedNavItem.allowedRoles.length == AppRole.values.length) {
          return null; // Not a controlled route, allow
        }

        if (path.startsWith('/manager') && currentUserRole != 'manager') {
          return _getInitialRouteForRole(currentUserRole);
        }
      }

      return null; // Allow
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ── Receptionist Shell ────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppNavigationWrapper(
          currentRoute: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.receptionistDashboard,
            name: 'receptionist-dashboard',
            builder: (context, state) => const ReceptionistDashboardBody(),
          ),
          GoRoute(
            path: AppRoutes.receptionistPatients,
            name: 'receptionist-patients',
            builder: (context, state) => const PatientListPage(),
          ),
          GoRoute(
            path: AppRoutes.receptionistAppointments,
            name: 'receptionist-appointments',
            builder: (context, state) => const AppointmentCalendarPage(),
          ),

          // ── Clinician / Specialist / Manager base routes ──────────────────
          GoRoute(
            path: AppRoutes.clinicianDashboard,
            name: 'clinician-dashboard',
            builder: (context, state) => const DoctorDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.specialistDashboard,
            name: 'specialist-dashboard',
            builder: (context, state) => const DoctorDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.managerReports,
            name: 'manager-reports',
            builder: (context, state) => const DoctorDashboardPage(),
          ),

          // Profile (shared)
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const _PlaceholderPage(title: 'Hồ sơ cá nhân'),
          ),
        ],
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
