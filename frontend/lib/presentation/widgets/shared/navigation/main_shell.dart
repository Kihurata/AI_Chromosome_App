import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/drawer_provider.dart';
import 'app_header.dart';
import 'app_side_rail.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(drawerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      endDrawer: drawerState.endDrawer,
      body: Row(
        children: [
          // Left: Side Rail
          const AppSideRail(),
          
          // Right: Content Area (Header + Main Page)
          Expanded(
            child: Column(
              children: [
                // Top: Rich Header
                const AppHeader(),
                
                // Bottom: Actual screen content
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
