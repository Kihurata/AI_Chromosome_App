import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'data/datasources/appointment_remote_datasource.dart';
import 'data/datasources/clinician_remote_datasource.dart';
import 'data/datasources/sample_remote_datasource.dart';
import 'data/datasources/test_order_remote_datasource.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'data/repositories/clinician_repository_impl.dart';
import 'data/repositories/sample_repository_impl.dart';
import 'data/repositories/test_order_repository_impl.dart';
import 'domain/usecases/appointment/create_appointment.dart';
import 'domain/usecases/appointment/get_today_appointments.dart';
import 'domain/usecases/appointment/get_appointments_in_range.dart';
import 'domain/usecases/appointment/watch_today_appointments.dart';
import 'domain/usecases/appointment/update_appointment_status.dart';
import 'domain/usecases/clinician/get_clinicians.dart';
import 'domain/usecases/sample/collect_physical_sample.dart';
import 'domain/usecases/sample/transfer_sample_to_lab.dart';
import 'domain/usecases/test_order/create_genetic_test_order.dart';
import 'domain/usecases/test_order/watch_all_orders.dart';
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
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<LayoutCubit>(create: (_) => getIt<LayoutCubit>()),
        BlocProvider<PatientCubit>(create: (_) => getIt<PatientCubit>()),

        // ── AppointmentCubit (Receptionist) ──────────────────────────────
        BlocProvider<AppointmentCubit>(create: (_) {
          final ds = FirebaseAppointmentRemoteDataSource(FirebaseFirestore.instance);
          final repo = AppointmentRepositoryImpl(ds);
          final clinicianDs = FirebaseClinicianRemoteDataSource();
          final clinicianRepo = ClinicianRepositoryImpl(remoteDataSource: clinicianDs);
          return AppointmentCubit(
            createAppointment: CreateAppointment(repo),
            getTodayAppointments: GetTodayAppointments(repo),
            getAppointmentsInRange: GetAppointmentsInRange(repo),
            watchTodayAppointments: WatchTodayAppointments(repo),
            updateAppointmentStatus: UpdateAppointmentStatus(repo),
            getClinicians: GetClinicians(clinicianRepo),
          );
        }),

        // ── ClinicianOrderCubit (Clinician) ───────────────────────────────
        BlocProvider<ClinicianOrderCubit>(create: (_) {
          final sampleDs = FirebaseSampleRemoteDataSource();
          final sampleRepo = SampleRepositoryImpl(remoteDataSource: sampleDs);
          final orderDs = FirebaseTestOrderRemoteDataSource();
          final orderRepo = TestOrderRepositoryImpl(remoteDataSource: orderDs);
          return ClinicianOrderCubit(
            createGeneticTestOrder: CreateGeneticTestOrder(orderRepo),
            collectPhysicalSample: CollectPhysicalSample(sampleRepo),
            transferSampleToLab: TransferSampleToLab(sampleRepo),
            watchAllOrders: WatchAllOrders(orderRepo),
          );
        }),

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
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  const ConnectivityBanner(),
                  Expanded(
                      child: MaterialApp.router(
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
                          return BlocListener<NotificationCubit, NotificationState>(
                            listener: (context, state) {
                              if (state is NotificationReceived) {
                                _handleIncomingNotification(context, state, router);
                              }
                            },
                            child: child!,
                          );
                        },
                      ),
                  ),
                ],
              ),
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
