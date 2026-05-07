import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/drawer_provider.dart';
import '../../../../core/models/filter_options.dart';
import '../../../../logic/bloc/manager/manager_dashboard_cubit.dart';
import '../../../../logic/bloc/manager/manager_dashboard_state.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/manager/lab_examination_table.dart';
import '../../widgets/shared/form/dashboard_filter_bar.dart';
import '../../widgets/shared/filter/advanced_filter_drawer.dart';
import '../../../core/services/notification_factory.dart';
import '../../../../logic/bloc/notification/notification_cubit.dart';

class LabManagerDashboardPage extends ConsumerStatefulWidget {
  const LabManagerDashboardPage({super.key});

  @override
  ConsumerState<LabManagerDashboardPage> createState() => _LabManagerDashboardPageState();
}

class _LabManagerDashboardPageState extends ConsumerState<LabManagerDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerDashboardCubit>().loadDashboard();
  }

  @override
  void dispose() {
    final drawer = ref.read(drawerProvider.notifier);
    // Clear global drawer when leaving the page
    Future.microtask(() {
      drawer.clear();
    });
    super.dispose();
  }

  bool _isDrawerRegistered = false;

  void _registerDrawer(WidgetRef ref, ManagerDashboardCubit cubit) {
    if (_isDrawerRegistered) return;
    _isDrawerRegistered = true;
    
    Future.microtask(() {
      if (!mounted) return;
      ref.read(drawerProvider.notifier).update(
            endDrawer: BlocProvider.value(
              value: cubit,
              child: BlocBuilder<ManagerDashboardCubit, ManagerDashboardState>(
                buildWhen: (p, c) {
                  if (p is ManagerDashboardLoaded && c is ManagerDashboardLoaded) {
                    return p.sortOrder != c.sortOrder || p.dateRangePreset != c.dateRangePreset;
                  }
                  return p.runtimeType != c.runtimeType;
                },
                builder: (context, state) {
                  if (state is! ManagerDashboardLoaded) return const SizedBox();
                  return AppAdvancedFilterDrawer(
                    currentSortOrder: state.sortOrder,
                    onSortOrderChanged: (sort) => cubit.updateFilters(sortOrder: sort),
                    currentDateRange: state.dateRangePreset,
                    onDateRangeChanged: (range) => cubit.updateFilters(dateRangePreset: range),
                    onApply: () {},
                    onClear: () => cubit.updateFilters(
                      searchQuery: '',
                      clearStatusFilter: true,
                      sortOrder: AppSortOrder.newest,
                      dateRangePreset: AppDateRangePreset.all,
                    ),
                  );
                },
              ),
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ManagerDashboardCubit>();
    _registerDrawer(ref, cubit);

    return MainListLayout(
      title: 'Hệ thống Bệnh viện',
      subtitle: 'Quản lý xét nghiệm di truyền',
      onRefresh: () async => cubit.loadDashboard(),
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
                cubit.focusOrder(state.relatedId);
              }
            },
          ),
        ],
        child: BlocBuilder<ManagerDashboardCubit, ManagerDashboardState>(
          builder: (context, state) {
            final loadedState = state is ManagerDashboardLoaded ? state : null;

            return Padding(
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
                          value: loadedState?.stats.unassignedCount.toString() ?? '0',
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
                          value: loadedState?.stats.ongoingCount.toString() ?? '0',
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
                          value: loadedState?.stats.waitingApprovalCount.toString() ?? '0',
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
                          value: loadedState?.stats.completedCount.toString() ?? '0',
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
                  
                  // Filter Bar
                  AppDashboardFilterBar(
                    searchHint: 'Tìm kiếm theo tên bệnh nhân, mã hoặc ID phiếu...',
                    initialSearchValue: loadedState?.searchQuery ?? '',
                    onSearchChanged: (v) => cubit.setSearchQuery(v),
                    onFilterPressed: () => Scaffold.of(context).openEndDrawer(),
                    hasActiveFilters: loadedState?.statusFilter != null || 
                        (loadedState?.dateRangePreset != AppDateRangePreset.all && loadedState?.dateRangePreset != null),
                  ),
                  const SizedBox(height: 24),

                  // Examination List
                  LabExaminationTable(
                    isLoading: state is ManagerDashboardLoading,
                    orders: loadedState?.filteredOrders ?? [],
                    specialists: loadedState?.specialists ?? [],
                    focusedOrderId: loadedState?.focusedOrderId,
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
