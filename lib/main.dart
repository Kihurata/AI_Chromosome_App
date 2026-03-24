import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/dashboard/doctor_dashboard_page.dart';

void main() {
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
    return MaterialApp(
      title: 'MedCore Hospital CRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DoctorDashboardPage(),
    );
  }
}
