import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'logic/bloc/auth/auth_cubit.dart';
import 'logic/bloc/layout/layout_cubit.dart';
import 'logic/bloc/patient/patient_cubit.dart';
import 'core/firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
      ],
      child: AuthBlocBridge(
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'MedCore CRM',
              theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
