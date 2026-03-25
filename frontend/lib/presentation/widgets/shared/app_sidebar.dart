import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.asterisk, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MedCore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Hospital CRM', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const Spacer(),
                const Icon(LucideIcons.menu, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Menu Items
          _buildNavItem(icon: LucideIcons.layoutGrid, title: 'Danh sách BN', isActive: true),
          _buildNavItem(icon: LucideIcons.users, title: 'Bệnh nhân', isActive: false),
          _buildNavItem(icon: LucideIcons.calendar, title: 'Lịch hẹn', isActive: false),
          _buildNavItem(icon: LucideIcons.microscope, title: 'Phòng Lab Phân tích AI', isActive: false),
          _buildNavItem(icon: LucideIcons.fileText, title: 'Hồ sơ y tế', isActive: false),
          
          const Spacer(),
          // Settings
          _buildNavItem(icon: LucideIcons.settings, title: 'Cài đặt', isActive: false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String title, required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.activeBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? AppColors.primaryBlue : AppColors.textSecondary, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
      ),
    );
  }
}
