import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/firebase/firebase_options.dart';
import 'core/services/connectivity_service.dart';
import 'logic/bloc/auth/auth_cubit.dart';
import 'logic/bloc/layout/layout_cubit.dart';
import 'logic/bloc/patient/patient_cubit.dart';
import 'logic/bloc/appointment/appointment_cubit.dart';
import 'logic/bloc/clinician/clinician_order_cubit.dart';
import 'logic/bloc/clinician/examination_cubit.dart';
import 'logic/bloc/manager/manager_dashboard_cubit.dart';
import 'logic/bloc/manager/manager_approval_cubit.dart';
import 'logic/bloc/connectivity/connectivity_cubit.dart';
import 'logic/bloc/notification/notification_cubit.dart';
import 'core/services/notification_factory.dart';
import 'presentation/widgets/shared/connectivity_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('vi', null);

  configureDependencies();

  runApp(const ProviderScope(child: MedCoreApp()));
}

class MedCoreApp extends ConsumerWidget {
  const MedCoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<LayoutCubit>(create: (_) => getIt<LayoutCubit>()),
        BlocProvider<PatientCubit>(create: (_) => getIt<PatientCubit>()),

        BlocProvider<AppointmentCubit>(create: (_) => getIt<AppointmentCubit>()),

        BlocProvider<ClinicianOrderCubit>(create: (_) => getIt<ClinicianOrderCubit>()),

        // ── ExaminationCubit (Clinician) ──────────────────────────────────
        BlocProvider<ExaminationCubit>(create: (_) => getIt<ExaminationCubit>()),

        // ── ManagerDashboardCubit (Manager) ──────────────────────────────
        BlocProvider<ManagerDashboardCubit>(create: (_) => getIt<ManagerDashboardCubit>()),

        // ── ManagerApprovalCubit (Manager) ───────────────────────────────
        BlocProvider<ManagerApprovalCubit>(create: (_) => getIt<ManagerApprovalCubit>()),

        // ── ConnectivityCubit ───────────────────────────────────────────
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(ConnectivityService()),
        ),
        BlocProvider<NotificationCubit>(
          create: (_) => NotificationCubit()..initialize(),
        ),
      ],
      child: AuthBlocBridge(
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'MedCore CRM',
              theme: ThemeData(
                useMaterial3: true,
                primarySwatch: Colors.blue,
              ),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('vi', 'VN'),
                Locale('en', 'US'),
              ],
              routerConfig: router,
              builder: (context, child) {
                return Column(
                  children: [
                    const ConnectivityBanner(),
                    Expanded(
                      child: BlocListener<NotificationCubit, NotificationState>(
                        listener: (context, state) {
                          if (state is NotificationReceived) {
                            _handleIncomingNotification(context, state, router);
                          }
                        },
                        child: child!,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleIncomingNotification(BuildContext context, NotificationReceived state, GoRouter router) {
    NotificationType uiType;
    String? targetRoute;
    final orderId = state.relatedId;
    
    // Mapping Backend types to UI types and determining navigation routes
    switch (state.type) {
      case 'ORDER_COMPLETED':
        uiType = NotificationType.success;
        if (orderId != null) targetRoute = '/clinician/test-result/$orderId';
        break;
      case 'ORDER_REJECTED':
        uiType = NotificationType.error;
        if (orderId != null) targetRoute = '/specialist/analysis/$orderId';
        break;
      case 'ORDER_PENDING':
      case 'ANALYSIS_READY':
        uiType = NotificationType.warning;
        if (state.type == 'ANALYSIS_READY' && orderId != null) {
          targetRoute = '/manager/review/$orderId';
        } else {
          targetRoute = AppRoutes.managerDashboard;
        }
        break;
      case 'ORDER_ASSIGNED':
        uiType = NotificationType.info;
        if (orderId != null) targetRoute = '/specialist/analysis/$orderId';
        break;
      default:
        uiType = NotificationType.info;
    }

    NotificationFactory.show(
      context,
      type: uiType,
      title: state.title,
      message: state.body,
      actionLabel: targetRoute != null ? 'Xem ngay' : null,
      onAction: targetRoute != null ? () {
        // Close snackbar/banner
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // If it's a dashboard focus case
        if (orderId != null && (state.type == 'ORDER_PENDING' || state.type == 'ANALYSIS_READY' || state.type == 'ORDER_ASSIGNED' || state.type == 'ORDER_COMPLETED' || state.type == 'ORDER_REJECTED')) {
          context.read<NotificationCubit>().onActionPressed(orderId, state.type);
          
          // Determine where to go
          if (state.type == 'ORDER_PENDING' || state.type == 'ANALYSIS_READY') {
            router.go(AppRoutes.managerDashboard);
          } else if (state.type == 'ORDER_ASSIGNED' || state.type == 'ORDER_REJECTED') {
            router.go(AppRoutes.specialistDashboard);
          } else {
            router.push(targetRoute!);
          }
        } else {
          router.push(targetRoute!);
        }
      } : null,
    );
  }
}
