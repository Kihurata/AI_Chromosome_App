import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/bloc/manager/manager_dashboard_cubit.dart';
import '../../../../logic/bloc/manager/manager_dashboard_state.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/manager/lab_examination_table.dart';
import '../../../core/services/notification_factory.dart';
import '../../../../logic/bloc/notification/notification_cubit.dart';

class LabManagerDashboardPage extends StatefulWidget {
  const LabManagerDashboardPage({super.key});

  @override
  State<LabManagerDashboardPage> createState() => _LabManagerDashboardPageState();
}

class _LabManagerDashboardPageState extends State<LabManagerDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerDashboardCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MainListLayout(
      title: 'Hệ thống Bệnh viện',
      subtitle: 'Quản lý xét nghiệm di truyền',
      child: MultiBlocListener(
        listeners: [
          BlocListener<ManagerDashboardCubit, ManagerDashboardState>(
            listener: (context, state) {
              if (state is ManagerDashboardError) {
                NotificationFactory.show(
                  context,
                  type: NotificationType.error,
                  title: 'Lỗi hệ thống',
                  message: state.message,
                );
              }
            },
          ),
          BlocListener<NotificationCubit, NotificationState>(
            listener: (context, state) {
              if (state is NotificationActionRequested && (state.type == 'ORDER_PENDING' || state.type == 'ANALYSIS_READY')) {
                context.read<ManagerDashboardCubit>().focusOrder(state.relatedId);
              }
            },
          ),
        ],
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
                    Expanded(
                      child: StatCard(
                        title: 'PHIẾU CHỜ CHỈ ĐỊNH',
                        value: (state is ManagerDashboardLoaded) ? state.stats.unassignedCount.toString() : '0',
                        trend: 'Unassigned',
                        isPositive: true,
                        icon: LucideIcons.fileSearch,
                        iconColor: const Color(0xFFF59E0B),
                        iconBgColor: const Color(0xFFFEF3C7),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: StatCard(
                        title: 'ĐANG THỰC HIỆN',
                        value: (state is ManagerDashboardLoaded) ? state.stats.ongoingCount.toString() : '0',
                        trend: 'In Progress',
                        isPositive: true,
                        icon: LucideIcons.activity,
                        iconColor: AppColors.primaryBlue,
                        iconBgColor: AppColors.activeBackground,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: StatCard(
                        title: 'CHỜ DUYỆT',
                        value: (state is ManagerDashboardLoaded) ? state.stats.waitingApprovalCount.toString() : '0',
                        trend: 'Needs Review',
                        isPositive: false,
                        icon: LucideIcons.clock,
                        iconColor: const Color(0xFFEF4444),
                        iconBgColor: const Color(0xFFFEE2E2),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: StatCard(
                        title: 'HOÀN THÀNH HÔM NAY',
                        value: (state is ManagerDashboardLoaded) ? state.stats.completedCount.toString() : '0',
                        trend: 'Achieved',
                        isPositive: true,
                        icon: LucideIcons.checkCircle,
                        iconColor: const Color(0xFF10B981),
                        iconBgColor: const Color(0xFFD1FAE5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Examination List
                LabExaminationTable(
                  isLoading: state is ManagerDashboardLoading,
                  orders: state is ManagerDashboardLoaded ? state.filteredOrders : [],
                  specialists: state is ManagerDashboardLoaded ? state.specialists : [],
                  focusedOrderId: state is ManagerDashboardLoaded ? state.focusedOrderId : null,
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
}
