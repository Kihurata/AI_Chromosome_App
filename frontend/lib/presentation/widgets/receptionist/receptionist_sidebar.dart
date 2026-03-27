import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ReceptionistSidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onItemTap;

  const ReceptionistSidebar({
    super.key,
    this.activeIndex = 0,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
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
                  child: const Icon(LucideIcons.asterisk, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MedCore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('Tiếp nhận', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildNavItem(icon: LucideIcons.layoutGrid, title: 'Tổng quan', index: 0),
          _buildNavItem(icon: LucideIcons.users, title: 'Danh sách BN', index: 1),
          _buildNavItem(icon: LucideIcons.calendarDays, title: 'Lịch hẹn', index: 2),
          _buildNavItem(icon: LucideIcons.clipboardList, title: 'Tiếp nhận', index: 3),
          const Spacer(),
          _buildNavItem(icon: LucideIcons.settings, title: 'Cài đặt', index: 4),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String title, required int index}) {
    final bool isActive = activeIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
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
        onTap: () => onItemTap?.call(index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true,
      ),
    );
  }
}
