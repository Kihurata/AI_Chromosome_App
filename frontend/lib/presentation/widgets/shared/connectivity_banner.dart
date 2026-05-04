import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/connectivity/connectivity_cubit.dart';
import '../../../core/theme/app_colors.dart';

/// A top-of-screen animated banner that appears when the device loses
/// network connectivity and disappears when it reconnects.
///
/// Place this widget at the top of the app shell (inside a [Column]
/// above the main content) so it is visible on every screen.
///
/// ```dart
/// Column(
///   children: [
///     const ConnectivityBanner(),
///     Expanded(child: mainContent),
///   ],
/// )
/// ```
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isOffline = state is ConnectivityOffline;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: isOffline ? 44 : 0,
          child: AnimatedOpacity(
            opacity: isOffline ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Material(
              color: AppColors.dangerText,
              elevation: 2,
              child: SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Mất kết nối mạng. Các thao tác sẽ được lưu tạm.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
