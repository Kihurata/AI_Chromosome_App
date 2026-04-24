import 'package:flutter/material.dart';
import '../navigation/app_header.dart';
import '../../../../core/theme/app_colors.dart';

class MainFormLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final Widget child;

  const MainFormLayout({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: title,
          subtitle: subtitle,
          showBackButton: showBackButton,
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
