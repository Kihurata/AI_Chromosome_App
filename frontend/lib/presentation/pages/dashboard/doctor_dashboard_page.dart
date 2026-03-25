import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/shared/app_sidebar.dart';
import '../../widgets/shared/app_header.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/recent_patients_table.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar Fixed width
          const AppSidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Header
                const AppHeader(),
                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stat Cards Row
                        Row(
                          children: [
                            const Expanded(
                              child: StatCard(
                                title: 'Xem lại các cập nhật thời gian\nthực về quy trình y tế',
                                value: '24',
                                trend: '+12% so với hôm qua',
                                isPositive: true,
                                icon: LucideIcons.fileSearch,
                                iconColor: AppColors.primaryBlue,
                                iconBgColor: AppColors.activeBackground,
                              ),
                            ),
                            const SizedBox(width: 24),
                            const Expanded(
                              child: StatCard(
                                title: 'Xem lại các cập nhật thời gian\nthực về quy trình y tế',
                                value: '12',
                                trend: '-2% so với hôm qua',
                                isPositive: false,
                                icon: LucideIcons.calendar,
                                iconColor: Color(0xFF6366F1), // Indigo
                                iconBgColor: Color(0xFFE0E7FF),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: StatCard(
                                title: 'Xem lại các cập nhật thời gian\nthực về quy trình y tế',
                                value: '05',
                                trend: '+5% tổng tăng trưởng',
                                isPositive: true,
                                icon: LucideIcons.bellRing,
                                iconColor: AppColors.dangerText,
                                iconBgColor: AppColors.dangerBg,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Data Table
                        const RecentPatientsTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
