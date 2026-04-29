import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Thêm import này
import 'core/di/injection.dart';
import 'core/router/app_router.dart';

void main() {
  // Đảm bảo Flutter binding được khởi tạo trước khi gọi DI
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Dependency Injection (GetIt)
  configureDependencies();

  // Phải bọc trong ProviderScope để sử dụng Riverpod
  runApp(const ProviderScope(child: MedCoreApp()));
}

class MedCoreApp extends ConsumerWidget {
  const MedCoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đọc config router từ provider đã định nghĩa trong app_router.dart
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MedCore CRM',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      // Sử dụng router từ provider
      routerConfig: router,
    );
  }
}
