import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/bloc/auth/auth_cubit.dart';

import '../../../../core/providers/header_provider.dart';

class AppHeader extends ConsumerWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final headerState = ref.watch(headerProvider);
    
    // Priority: Explicit parameters > Provider state
    final effectiveTitle = title ?? headerState.title;
    final effectiveSubtitle = subtitle ?? headerState.subtitle;
    final effectiveActions = actions ?? headerState.actions;
    final effectiveShowBackButton = showBackButton || (headerState.showBackButton ?? false);

    String currentPath = '/';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {}

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (effectiveShowBackButton) ...[
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, size: 20),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
          ],
          // Breadcrumbs or Title
          Expanded(
            child: effectiveTitle != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        effectiveTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (effectiveSubtitle != null && effectiveSubtitle.isNotEmpty)
                        Text(
                          effectiveSubtitle,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                    ],
                  )
                : _buildBreadcrumbs(context, currentPath),
          ),
          
          const SizedBox(width: 24),

          if (effectiveActions != null) ...[
            ...effectiveActions,
            const SizedBox(width: 20),
          ],
          
          // Notification Bell
          _buildNotificationBell(),
          
          const SizedBox(width: 20),
          Container(
            width: 1,
            height: 30,
            color: AppColors.border,
          ),
          const SizedBox(width: 20),
          
          // User Profile
          _buildUserProfile(context, auth),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      return const Text(
        'Dashboard',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
    }

    List<Widget> crumbs = [];
    String currentBuildPath = '';

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      currentBuildPath += '/$segment';
      final label = _getLabelForSegment(segment);
      final isLast = i == segments.length - 1;

      crumbs.add(
        InkWell(
          onTap: isLast ? null : () => context.go(currentBuildPath),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              color: isLast ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      );

      if (!isLast) {
        crumbs.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textPlaceholder),
          ),
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: crumbs),
    );
  }

  String _getLabelForSegment(String segment) {
    switch (segment) {
      case 'receptionist': return 'Tiếp nhận';
      case 'dashboard': return 'Tổng quan';
      case 'patients': return 'Bệnh nhân';
      case 'appointments': return 'Lịch khám';
      case 'clinician': return 'Bác sĩ';
      case 'specialist': return 'Chuyên khoa';
      case 'analysis': return 'Phân tích NST';
      case 'manager': return 'Quản lý';
      case 'reports': return 'Báo cáo';
      case 'staff': return 'Nhân viên';
      case 'profile': return 'Hồ sơ';
      default: 
        if (segment.length > 20) return 'Chi tiết'; // Likely a UUID
        return segment[0].toUpperCase() + segment.substring(1);
    }
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary, size: 20),
          onPressed: () {},
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.dangerText,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context, AuthSnapshot auth) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              auth.displayName,
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold, 
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              auth.role?.displayName ?? 'Nhân viên',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryBlue.withAlpha(30),
            child: Text(
              auth.userInitial,
              style: const TextStyle(
                color: AppColors.primaryBlue, 
                fontWeight: FontWeight.bold, 
                fontSize: 13,
              ),
            ),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthCubit>().logout();
              context.go('/login');
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(LucideIcons.user, size: 16),
                  SizedBox(width: 10),
                  Text('Hồ sơ cá nhân', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(LucideIcons.logOut, size: 16, color: AppColors.dangerText),
                  SizedBox(width: 10),
                  Text(
                    'Đăng xuất', 
                    style: TextStyle(color: AppColors.dangerText, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
