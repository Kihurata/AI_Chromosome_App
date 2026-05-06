import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../../logic/bloc/appointment/appointment_state.dart';
import '../../../widgets/dashboard/stat_card.dart';
import '../../../widgets/dashboard/recent_patients_table.dart';
import '../../../widgets/shared/layouts/main_list_layout.dart';

class DoctorDashboardPage extends StatelessWidget {
  const DoctorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainListLayout(
      title: 'Bảng điều khiển bác sĩ',
      subtitle: 'Tổng quan lịch khám và bệnh nhân',
      child: BlocBuilder<AppointmentCubit, AppointmentState>(
        builder: (context, state) {
          final appointments = state is AppointmentLoaded ? state.appointments : [];
          final todayCount = appointments.length;
          final pendingCount = appointments.where((a) => a.status == 'scheduled').length;
          final urgentCount = appointments.where((a) => a.status == 'urgent').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Cards Row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'BỆNH NHÂN HÔM NAY',
                        value: todayCount.toString(),
                        trend: '+12% so với hôm qua',
                        isPositive: true,
                        icon: LucideIcons.users,
                        iconColor: AppColors.primaryBlue,
                        iconBgColor: AppColors.activeBackground,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: StatCard(
                        title: 'LỊCH HẸN CHỜ KHÁM',
                        value: pendingCount.toString(),
                        trend: 'Sắp diễn ra',
                        isPositive: true,
                        icon: LucideIcons.calendar,
                        iconColor: const Color(0xFF6366F1), // Indigo
                        iconBgColor: const Color(0xFFE0E7FF),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: StatCard(
                        title: 'CA KHẨN CẤP',
                        value: urgentCount.toString(),
                        trend: 'Cần xử lý ngay',
                        isPositive: false,
                        icon: LucideIcons.alertCircle,
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
          );
        },
      ),
    );
  }
}

