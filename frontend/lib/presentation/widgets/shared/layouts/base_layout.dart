import 'package:flutter/material.dart';
import '../navigation/app_header.dart';
import '../../../../core/theme/app_colors.dart';

class BaseLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? headerActions;
  final bool showBackButton;
  final Widget child;
  final bool useScrolling;
  final EdgeInsetsGeometry? padding;
  final Widget? background;

  const BaseLayout({
    super.key,
    required this.title,
    required this.subtitle,
    this.headerActions,
    this.showBackButton = false,
    required this.child,
    this.useScrolling = false,
    this.padding,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = padding != null 
        ? Padding(padding: padding!, child: child) 
        : child;

    if (useScrolling) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return Column(
      children: [
        AppHeader(
          title: title,
          subtitle: subtitle,
          actions: headerActions,
          showBackButton: showBackButton,
        ),
        Expanded(
          child: Stack(
            children: [
              // Background layer
              background ?? Container(color: AppColors.background),
              // Content layer
              SizedBox.expand(child: content),
            ],
          ),
        ),
      ],
    );
  }
}
