import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Thêm import này
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'logic/bloc/patient/patient_cubit.dart'; // Thêm import này

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter đã sẵn sàng
  configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Dùng MultiBlocProvider để quản lý các Cubit của App
    return MultiBlocProvider(
      providers: [
        // Lấy PatientCubit từ trong "Hộp GetIt" ra và cung cấp cho App
        BlocProvider(create: (context) => getIt<PatientCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MedCore CRM',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true, // Dùng giao diện Material 3 hiện đại
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
