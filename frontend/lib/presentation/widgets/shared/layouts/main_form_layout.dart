import 'package:flutter/material.dart';
import 'base_layout.dart';
import '../containers/app_card.dart';
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
    return BaseLayout(
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      useScrolling: true,
      padding: const EdgeInsets.all(28.0),
      child: Center(
        child: AppCard(
          constraints: const BoxConstraints(maxWidth: 800),
          child: child,
        ),
      ),
    );
  }
}
