import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/nav_item.dart';
import '../config/app_nav_items.dart';
import '../providers/auth_provider.dart';
import '../../presentation/screens/auth/login_page.dart';
import '../../presentation/screens/receptionist/receptionist_dashboard_body.dart';
import '../../presentation/screens/receptionist/patient_list_page.dart';
import '../../presentation/screens/receptionist/appointment_calendar_page.dart';
import '../../presentation/screens/dashboard/doctor_dashboard_page.dart';
import '../../presentation/screens/specialist/specialist_dashboard_page.dart';
import '../../presentation/widgets/shared/navigation/main_shell.dart';
import '../../presentation/screens/clinician/appointment_list/appointment_list_screen.dart';
import '../../presentation/screens/clinician/medical_record/medical_record_screen.dart';
import '../../presentation/screens/clinician/examination_form_screen.dart';
import '../../presentation/screens/clinician/blood_test_prescription_screen.dart';
import '../../presentation/screens/workspace/workspace_screen.dart';
import '../../presentation/screens/manager/manager_dashboard_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/specialist/ai_analysis_cubit.dart';
import '../../logic/bloc/workspace/workspace_cubit.dart';
import '../../logic/bloc/specialist/sample_management_cubit.dart';
import '../../presentation/screens/specialist/sample_management_page.dart';
import '../../domain/usecases/specialist/update_chromosome_position.dart';
import '../../domain/usecases/test_order/submit_analysis_result.dart';
import '../di/injection.dart';

// ── Route path constants ──────────────────────────────────────────────────────
class AppRoutes {
  static const login = '/login';

  // Receptionist
  static const receptionistDashboard = '/receptionist/dashboard';
  static const receptionistPatients = '/receptionist/patients';
  static const receptionistAppointments = '/receptionist/appointments';

  // Clinician
  static const clinicianDashboard = '/clinician/dashboard';
  static const clinicianAppointments = '/clinician/appointments';
  static const clinicianMedicalRecord = '/clinician/medical-record';
  static const clinicianExaminationForm = '/clinician/examination-form';
  static const clinicianBloodTest = '/clinician/blood-test-prescription';
  static const clinicianLab = '/clinician/lab';

  // Specialist
  static const specialistDashboard = '/specialist/dashboard';
  static const specialistAnalysis = '/specialist/analysis';
  static const specialistSamples = '/specialist/samples';

  // Manager
  static const managerDashboard = '/manager/dashboard';
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

        if (!matchedNavItem.isAllowedFor(role)) {
          // Forbidden — redirect to their own home
          return defaultRouteForRole(role);
        }
      }

      return null; // Allow
    },

    // ── ROUTES ───────────────────────────────────────────────────────────────
    routes: [
      // Public route
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ── Main App Shell ────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
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
            path: AppRoutes.clinicianAppointments,
            name: 'clinician-appointments',
            builder: (context, state) => const ClinicianAppointmentListPage(),
          ),
          GoRoute(
            path: '${AppRoutes.clinicianMedicalRecord}/:id',
            name: 'clinician-medical-record',
            builder: (context, state) => ClinicianMedicalRecordPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '${AppRoutes.clinicianExaminationForm}/:id',
            name: 'clinician-examination-form',
            builder: (context, state) => ClinicianExaminationFormPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: '${AppRoutes.clinicianBloodTest}/:id',
            name: 'clinician-blood-test',
            builder: (context, state) => ClinicianBloodTestPrescriptionPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoutes.specialistDashboard,
            name: 'specialist-dashboard',
            builder: (context, state) => const SpecialistDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.specialistSamples,
            name: 'specialist-samples',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<SampleManagementCubit>()),
                BlocProvider(create: (_) => getIt<AiAnalysisCubit>()),
              ],
              child: const SampleManagementPage(),
            ),
          ),
          GoRoute(
            path: '${AppRoutes.specialistAnalysis}/:orderId',
            name: 'specialist-analysis',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId'] ?? '';
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => getIt<AiAnalysisCubit>()),
                  BlocProvider(
                    create: (_) => WorkspaceCubit(
                      updatePositionUsecase: getIt<UpdateChromosomePosition>(),
                      submitAnalysisUsecase: getIt<SubmitAnalysisResult>(),
                      orderId: orderId,
                    ),
                  ),
                ],
                child: WorkspaceScreen(
                  orderId: orderId,
                ),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.managerDashboard,
            name: 'manager-dashboard',
            builder: (context, state) => const ManagerDashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.managerReports,
            name: 'manager-reports',
            builder: (context, state) => const _PlaceholderPage(title: 'Báo cáo Lab'),
          ),

          // Profile (shared)
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const _PlaceholderPage(title: 'Hồ sơ cá nhân'),
          ),
        ],
      ),

      // 403 page
      GoRoute(
        path: AppRoutes.forbidden,
        name: 'forbidden',
        builder: (context, state) => const _ForbiddenPage(),
      ),
    ],
  );
});

// ── Listens to auth state changes to trigger GoRouter refresh ─────────────────
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authNotifierProvider, (previous, current) => notifyListeners());
  }
}

/// Placeholder for pages not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
      ),
    );
  }
}

class _ForbiddenPage extends StatelessWidget {
  const _ForbiddenPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '403',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn không có quyền truy cập trang này',
              style: TextStyle(fontSize: 16, color: Color(0xFF6C757D)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Quay về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
