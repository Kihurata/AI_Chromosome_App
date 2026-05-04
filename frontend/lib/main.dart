import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/firebase/firebase_options.dart';
import 'logic/bloc/auth/auth_cubit.dart';
import 'logic/bloc/layout/layout_cubit.dart';
import 'logic/bloc/patient/patient_cubit.dart';
import 'logic/bloc/appointment/appointment_cubit.dart';
import 'logic/bloc/clinician/clinician_order_cubit.dart';
import 'logic/bloc/clinician/examination_cubit.dart';
import 'logic/bloc/manager/manager_dashboard_cubit.dart';
import 'logic/bloc/manager/manager_approval_cubit.dart';
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
// Examination imports removed as they are now handled by getIt


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
            );
          },
        ),
      ),
    );
  }
}
