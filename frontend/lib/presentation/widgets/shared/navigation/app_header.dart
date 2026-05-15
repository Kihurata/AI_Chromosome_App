import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/bloc/auth/auth_cubit.dart';
import '../../../../logic/bloc/notification/notification_cubit.dart';

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
    final rawState = context.watch<NotificationCubit>().state;
    final notifState = rawState is NotificationListState
        ? rawState
        : const NotificationListState();
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
              onPressed: onBack ?? () {
                if (GoRouter.of(context).canPop()) {
                  context.pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
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
          _buildNotificationBell(context, notifState),
          
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

  Widget _buildNotificationBell(BuildContext context, NotificationListState notifState) {
    final int unread = notifState.unreadCount;
    final List<NotificationItem> notifications = notifState.notifications;

    return PopupMenuButton<int>(
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 360),
      color: AppColors.surface,
      onOpened: () => context.read<NotificationCubit>().markAllRead(),
      itemBuilder: (ctx) => [
        PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _NotificationDropdown(notifications: notifications),
        ),
      ],
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(LucideIcons.bell, color: AppColors.textSecondary, size: 20),
          ),
          if (unread > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.dangerText,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 16),
                child: Text(
                  unread > 99 ? '99+' : unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
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

// ---------------------------------------------------------------------------
// Notification dropdown panel (shown inside the PopupMenuButton)
// ---------------------------------------------------------------------------
class _NotificationDropdown extends StatelessWidget {
  final List<NotificationItem> notifications;

  const _NotificationDropdown({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.bell, size: 16, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Thông báo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${notifications.length} tin',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // List or empty state
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.bellOff, size: 28, color: AppColors.textPlaceholder),
                    SizedBox(height: 8),
                    Text(
                      'Chưa có thông báo nào',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (context, idx) =>
                    const Divider(height: 1, thickness: 1, color: AppColors.border),
                itemBuilder: (ctx, i) =>
                    _NotificationTile(item: notifications[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: _dotColor(item.type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.body,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTime(item.receivedAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textPlaceholder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _dotColor(String type) {
    switch (type) {
      case 'ORDER_COMPLETED':
        return AppColors.successText;
      case 'ORDER_REJECTED':
        return AppColors.dangerText;
      case 'ORDER_PENDING':
      case 'ANALYSIS_READY':
        return AppColors.warningText;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
