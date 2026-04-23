import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';

void main() {
  // 1. Chạy hàm này để khởi tạo cái "Hộp GetIt" của chúng ta
  configureDependencies();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MedCore CRM',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Báo cho Flutter biết: Hãy giao việc điều hướng cho AppRouter.router quản lý
      routerConfig: AppRouter.router,
    );
  }
}
