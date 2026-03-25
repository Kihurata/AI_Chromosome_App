import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/dashboard/doctor_dashboard_page.dart';
import 'presentation/cubits/auth/auth_cubit.dart';
import 'presentation/pages/auth/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print("Firebase initialization error: $e");
    }
  }

  runApp(
    // Wrap the app with ProviderScope to enable Riverpod
    const ProviderScope(
      child: MedCoreApp(),
    ),
  );
}

class MedCoreApp extends StatelessWidget {
  const MedCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'MedCore Hospital CRM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const DoctorDashboardPage();
            } else if (state is AuthInitial || state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
