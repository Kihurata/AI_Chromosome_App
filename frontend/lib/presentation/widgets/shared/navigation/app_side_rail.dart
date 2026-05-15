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

  static const double _expandedWidth = 240;
  static const double _collapsedWidth = 72;
  static const Duration _animDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navItems = ref.watch(filteredNavItemsProvider);
    String currentPath = '/';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {}

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final isCollapsed = state.isSidebarCollapsed;

        return AnimatedContainer(
          duration: _animDuration,
          curve: Curves.easeInOut,
          width: isCollapsed ? _collapsedWidth : _expandedWidth,
          // ClipRect ngăn nội dung tràn ra ngoài trong lúc animation
          child: ClipRect(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(right: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Column(
                children: [
                  _buildHeader(context, isCollapsed),
                  const Divider(height: 1, color: AppColors.border),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isCollapsed) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nội dung khi MỞ rộng — fade out khi thu gọn
          AnimatedOpacity(
            opacity: isCollapsed ? 0.0 : 1.0,
            duration: isCollapsed
                ? const Duration(milliseconds: 80) // ẩn nhanh khi đóng
                : const Duration(milliseconds: 200), // hiện chậm khi mở
            child: IgnorePointer(
              ignoring: isCollapsed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryBlue, Color(0xFF4A9DFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withAlpha(40),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.activity, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MedCore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Hospital CRM',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<LayoutCubit>().toggleSidebar(),
                      icon: const Icon(LucideIcons.panelLeftClose, size: 18),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Nút mở rộng — chỉ hiển thị khi thu gọn
          AnimatedOpacity(
            opacity: isCollapsed ? 1.0 : 0.0,
            duration: isCollapsed
                ? const Duration(milliseconds: 200)
                : const Duration(milliseconds: 80),
            child: IgnorePointer(
              ignoring: !isCollapsed,
              child: IconButton(
                onPressed: () => context.read<LayoutCubit>().toggleSidebar(),
                icon: const Icon(LucideIcons.panelLeftOpen, size: 20),
                color: AppColors.textSecondary,
              ),
            ),
          ),
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
          child: AnimatedContainer(
            duration: _animDuration,
            curve: Curves.easeInOut,
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.activeBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Icon — luôn hiển thị, canh giữa khi thu gọn
                AnimatedContainer(
                  duration: _animDuration,
                  curve: Curves.easeInOut,
                  width: isCollapsed ? 55 : 36,
                  alignment: Alignment.center,
                  child: Icon(
                    isActive ? (item.activeIcon ?? item.icon) : item.icon,
                    color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                // Label — hiển thị khi KHÔNG thu gọn
                Expanded(
                  child: AnimatedOpacity(
                    opacity: isCollapsed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
