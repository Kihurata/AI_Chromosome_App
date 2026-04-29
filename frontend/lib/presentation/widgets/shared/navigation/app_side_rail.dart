import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/providers/nav_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/bloc/layout/layout_cubit.dart';
import '../../../../logic/bloc/layout/layout_state.dart';

class AppSideRail extends ConsumerWidget {
  const AppSideRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navItems = ref.watch(filteredNavItemsProvider);
    // Try to get current path from GoRouterState, fallback to root if not available
    String currentPath = '/';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {}

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final isCollapsed = state.isSidebarCollapsed;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: isCollapsed ? 72 : 240,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(right: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Column(
            children: [
              // Header / Logo
              _buildHeader(context, isCollapsed),
              const Divider(height: 1, color: AppColors.border),
              
              // Nav Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  itemCount: navItems.length,
                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isActive = currentPath.startsWith(item.routePath);
                    return _buildNavItem(context, item, isActive, isCollapsed);
                  },
                ),
              ),
              
              // Profile Area or Toggle Button at bottom
              const Divider(height: 1, color: AppColors.border),
              _buildFooter(context, isCollapsed),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isCollapsed) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 16 : 20),
      child: Row(
        mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, Color(0xFF4A9DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(LucideIcons.activity, color: Colors.white, size: 20),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MedCore',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Hospital CRM',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, dynamic item, bool isActive, bool isCollapsed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(item.routePath),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.activeBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isActive ? (item.activeIcon ?? item.icon) : item.icon,
                  color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isCollapsed) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              isCollapsed ? LucideIcons.panelLeftOpen : LucideIcons.panelLeftClose,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => context.read<LayoutCubit>().toggleSidebar(),
          ),
        ],
      ),
    );
  }
}
