import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'sidebar_base.dart';

class AppSidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onItemTap;

  const AppSidebar({
    super.key,
    this.activeIndex = 0,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      SidebarItemData(icon: LucideIcons.layoutGrid, title: 'Danh sách BN', index: 0),
      SidebarItemData(icon: LucideIcons.users, title: 'Bệnh nhân', index: 1),
      SidebarItemData(icon: LucideIcons.calendar, title: 'Lịch hẹn', index: 2),
      SidebarItemData(icon: LucideIcons.microscope, title: 'Phòng Lab AI', index: 3),
      SidebarItemData(icon: LucideIcons.fileText, title: 'Hồ sơ y tế', index: 4),
      SidebarItemData(icon: LucideIcons.settings, title: 'Cài đặt', index: 5),
    ];

    return SidebarBase(
      title: 'MedCore',
      subtitle: 'Hospital CRM',
      logoIcon: LucideIcons.asterisk,
      items: items,
      activeIndex: activeIndex,
      onItemTap: onItemTap,
      width: 260,
    );
  }
}
