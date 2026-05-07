import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/drawer_provider.dart';
import '../../../core/models/filter_options.dart';
import '../../../logic/bloc/appointment/appointment_cubit.dart';
import '../../../logic/bloc/appointment/appointment_state.dart';
import '../../../domain/entities/appointment.dart';
import '../../widgets/receptionist/today_appointments_table.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../widgets/shared/form/dashboard_filter_bar.dart';
import '../../widgets/shared/filter/advanced_filter_drawer.dart';
import 'patient_registration_page.dart';

/// Slim receptionist dashboard — no sidebar/header (handled by AppNavigationWrapper).
class ReceptionistDashboardBody extends ConsumerWidget {
  const ReceptionistDashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cubit = context.read<AppointmentCubit>();

    // Register advanced filter drawer for this page
    Future.microtask(() {
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
    });

    return MainListLayout(
      title: 'Tổng quan',
      subtitle: 'Theo dõi hoạt động tiếp nhận hôm nay',
      headerActions: [
        AppPrimaryButton(
          text: 'Thêm bệnh nhân',
          icon: LucideIcons.userPlus,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PatientRegistrationPage(),
            ),
          ),
        ),
      ],
      onRefresh: () async => cubit.listenToTodayAppointments(),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat Cards via BlocBuilder
            BlocBuilder<AppointmentCubit, AppointmentState>(
              builder: (context, state) {
                int total = 0, pending = 0, completed = 0;
                if (state is AppointmentLoaded) {
                  total = state.allAppointments.length;
                  pending = state.allAppointments.where((a) => a.status == AppointmentStatus.scheduled).length;
                  completed = state.allAppointments.where((a) => a.status == AppointmentStatus.completed).length;
                }
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Lịch hẹn hôm nay',
                        value: total.toString().padLeft(2, '0'),
                        trend: 'Tổng số hồ sơ',
                        isPositive: true,
                        icon: LucideIcons.calendarDays,
                        iconColor: AppColors.primaryBlue,
                        iconBgColor: AppColors.activeBackground,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: StatCard(
                        title: 'Đang chờ tiếp nhận',
                        value: pending.toString().padLeft(2, '0'),
                        trend: 'Cần xử lý ngay',
                        isPositive: pending > 0 ? false : true,
                        icon: LucideIcons.hourglass,
                        iconColor: AppColors.warningText,
                        iconBgColor: AppColors.warningBg,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: StatCard(
                        title: 'Đã hoàn tất hôm nay',
                        value: completed.toString().padLeft(2, '0'),
                        trend: 'Đã xong quy trình',
                        isPositive: true,
                        icon: LucideIcons.checkCircle,
                        iconColor: AppColors.successText,
                        iconBgColor: AppColors.successBg,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Filter Bar
            BlocBuilder<AppointmentCubit, AppointmentState>(
              buildWhen: (p, c) {
                if (p is AppointmentLoaded && c is AppointmentLoaded) {
                  return p.searchQuery != c.searchQuery || p.dateRangePreset != c.dateRangePreset;
                }
                return false;
              },
              builder: (context, state) {
                final loadedState = state is AppointmentLoaded ? state : null;
                return AppDashboardFilterBar(
                  searchHint: 'Tìm kiếm theo tên hoặc mã bệnh nhân...',
                  initialSearchValue: loadedState?.searchQuery ?? '',
                  onSearchChanged: (v) => cubit.setSearchQuery(v),
                  onFilterPressed: () => Scaffold.of(context).openEndDrawer(),
                  hasActiveFilters: loadedState?.dateRangePreset != AppDateRangePreset.all,
                );
              },
            ),
            const SizedBox(height: 20),

            // Appointments Table
            const TodayAppointmentsTable(),
          ],
        ),
      ),
    );
  }
}
