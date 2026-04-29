import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/header_provider.dart';
import '../../../../core/theme/app_colors.dart';

class MainListLayout extends ConsumerWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? headerActions;
  final Widget child;
  final Future<void> Function()? onRefresh;

  const MainListLayout({
    super.key,
    this.title,
    this.subtitle,
    this.headerActions,
    required this.child,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dynamically update the global AppHeader in MainShell
    if (title != null || subtitle != null || headerActions != null) {
      Future.microtask(() {
        ref.read(headerProvider.notifier).update(
          title: title,
          subtitle: subtitle,
          actions: headerActions,
        );
      });
    }

    Widget content = Container(
      color: AppColors.background,
      width: double.infinity,
      child: child,
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: content,
        ),
      );
    }

    return content;
  }
}
