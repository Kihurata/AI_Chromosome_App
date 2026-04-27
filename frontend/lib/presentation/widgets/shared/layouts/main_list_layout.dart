import 'package:flutter/material.dart';
import '../navigation/app_header.dart';
import '../../../../core/theme/app_colors.dart';

class MainListLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? headerActions;
  final Widget child;

  const MainListLayout({
    super.key,
    required this.title,
    required this.subtitle,
    this.headerActions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          title: title,
          subtitle: subtitle,
          actions: headerActions,
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            width: double.infinity,
            child: child,
          ),
        ),
      ],
    );
  }
}
