import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/drawer_provider.dart';
import '../../../../core/models/filter_options.dart';
import '../../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../../logic/bloc/appointment/appointment_state.dart';
import '../../../widgets/dashboard/stat_card.dart';
import '../../../widgets/dashboard/recent_patients_table.dart';
import '../../../widgets/shared/layouts/main_list_layout.dart';
import '../../../widgets/shared/form/dashboard_filter_bar.dart';
import '../../../widgets/shared/filter/advanced_filter_drawer.dart';

class DoctorDashboardPage extends ConsumerStatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  ConsumerState<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends ConsumerState<DoctorDashboardPage> {
  bool _isDrawerRegistered = false;

  void _registerDrawer(WidgetRef ref, AppointmentCubit cubit) {
    if (_isDrawerRegistered) return;
    _isDrawerRegistered = true;

    ref.read(drawerProvider.notifier).update(
          endDrawer: BlocProvider.value(
            value: cubit,
            child: BlocBuilder<AppointmentCubit, AppointmentState>(
              buildWhen: (p, c) {
                if (p is AppointmentLoaded && c is AppointmentLoaded) {
                  return p.sortOrder != c.sortOrder || p.dateRangePreset != c.dateRangePreset;
                }
                return false;
              },
              builder: (context, state) {
                if (state is! AppointmentLoaded) return const SizedBox();
                return AppAdvancedFilterDrawer(
                  currentSortOrder: state.sortOrder,
                  onSortOrderChanged: (sort) => cubit.updateFilters(sortOrder: sort),
                  currentDateRange: state.dateRangePreset,
                  onDateRangeChanged: (range) => cubit.updateFilters(dateRangePreset: range),
                  onApply: () {},
                  onClear: () => cubit.updateFilters(
                    searchQuery: '',
                    sortOrder: AppSortOrder.newest,
                    dateRangePreset: AppDateRangePreset.all,
                  ),
                );
              },
            ),
          ),
        );
  }

  @override
  void initState() {
    super.initState();
    // Clear drawer from previous pages before registering new one
    ref.read(drawerProvider.notifier).clear();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<AppointmentCubit>();
      _registerDrawer(ref, cubit);
    });
  }

  late ProviderContainer _container;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container = ProviderScope.containerOf(context);
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    Future.microtask(() {
      _container.read(drawerProvider.notifier).clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppointmentCubit>();

    return MainListLayout(
      title: 'Bảng điều khiển bác sĩ',
      subtitle: 'Tổng quan lịch khám và bệnh nhân',
      onRefresh: () async => cubit.listenToTodayAppointments(),
      child: BlocBuilder<AppointmentCubit, AppointmentState>(
        builder: (context, state) {
          final loadedState = state is AppointmentLoaded ? state : null;
          final appointments = loadedState?.allAppointments ?? [];
          
          final todayCount = appointments.length;
          final pendingCount = appointments.where((a) => a.status.name == 'scheduled').length;
          final urgentCount = appointments.where((a) => a.status.name == 'urgent').length;

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

                // Filter Bar
                AppDashboardFilterBar(
                  searchHint: 'Tìm kiếm theo tên bệnh nhân hoặc mã...',
                  initialSearchValue: loadedState?.searchQuery ?? '',
                  onSearchChanged: (v) => cubit.setSearchQuery(v),
                  onFilterPressed: () => Scaffold.of(context).openEndDrawer(),
                  hasActiveFilters: loadedState?.dateRangePreset != AppDateRangePreset.all,
                ),
                const SizedBox(height: 24),

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
