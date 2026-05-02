import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/bloc/manager/manager_dashboard_cubit.dart';
import '../../../../logic/bloc/manager/manager_dashboard_state.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/manager/lab_examination_table.dart';

class LabManagerDashboardPage extends StatefulWidget {
  const LabManagerDashboardPage({super.key});

  @override
  State<LabManagerDashboardPage> createState() => _LabManagerDashboardPageState();
}

class _LabManagerDashboardPageState extends State<LabManagerDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerDashboardCubit>().fetchPendingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return MainListLayout(
      title: 'Hệ thống Bệnh viện',
      subtitle: 'Quản lý xét nghiệm di truyền',
      child: BlocBuilder<ManagerDashboardCubit, ManagerDashboardState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Cards Row
                Row(
                  children: [
                    const Expanded(
                      child: StatCard(
                        title: 'PHIẾU CHỜ CHỈ ĐỊNH',
                        value: '12',
                        trend: '+2 New',
                        isPositive: true,
                        icon: LucideIcons.fileSearch,
                        iconColor: Color(0xFFF59E0B),
                        iconBgColor: Color(0xFFFEF3C7),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: StatCard(
                        title: 'ĐANG THỰC HIỆN',
                        value: '08',
                        trend: 'In Progress',
                        isPositive: true,
                        icon: LucideIcons.activity,
                        iconColor: AppColors.primaryBlue,
                        iconBgColor: AppColors.activeBackground,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: StatCard(
                        title: 'CHỜ DUYỆT',
                        value: '05',
                        trend: 'Needs Review',
                        isPositive: false,
                        icon: LucideIcons.clock,
                        iconColor: Color(0xFFEF4444),
                        iconBgColor: Color(0xFFFEE2E2),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(
                      child: StatCard(
                        title: 'HOÀN THÀNH HÔM NAY',
                        value: '24',
                        trend: 'Achieved',
                        isPositive: true,
                        icon: LucideIcons.checkCircle,
                        iconColor: Color(0xFF10B981),
                        iconBgColor: Color(0xFFD1FAE5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Examination List
                LabExaminationTable(
                  isLoading: state is ManagerDashboardLoading,
                  orders: state is ManagerDashboardLoaded ? state.pendingOrders : [],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
