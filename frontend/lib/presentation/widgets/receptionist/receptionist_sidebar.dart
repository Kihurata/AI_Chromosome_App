import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../shared/sidebar_base.dart';

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
    const items = [
      SidebarItemData(icon: LucideIcons.layoutDashboard, title: 'Tổng quan', index: 0),
      SidebarItemData(icon: LucideIcons.users, title: 'Bệnh nhân', index: 1),
      SidebarItemData(icon: LucideIcons.calendarDays, title: 'Lịch khám', index: 2),
    ];

    return SidebarBase(
      title: 'MedCore',
      subtitle: 'Tiếp nhận',
      logoIcon: LucideIcons.activity,
      items: items,
      activeIndex: activeIndex,
      onItemTap: onItemTap,
      width: 230,
      bottomAction: _buildProfileSection(),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.activeBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryBlue,
            child: const Text('L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lê Thị Lan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text('Lễ tân', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(LucideIcons.logOut, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
