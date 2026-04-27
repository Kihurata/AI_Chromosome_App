import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton) ...[
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onBack ?? () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.border.withAlpha(60),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.arrowLeft, color: AppColors.textSecondary, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
          // Page Title
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          
          if (actions != null) ...actions!,
          const SizedBox(width: 24),
          
          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.dangerText, shape: BoxShape.circle),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          
          // User Profile (Mock for now, can be read from AuthNotifier later)
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryBlue,
                child: const Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tài khoản', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Nhân viên', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

