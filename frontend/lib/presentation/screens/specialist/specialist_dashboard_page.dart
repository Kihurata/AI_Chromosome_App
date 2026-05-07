import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/drawer_provider.dart';
import '../../../../core/models/filter_options.dart';
import '../../../logic/bloc/specialist/specialist_dashboard_cubit.dart';
import '../../../logic/bloc/specialist/specialist_dashboard_state.dart';
import '../../../logic/bloc/notification/notification_cubit.dart';
import '../../widgets/shared/layouts/main_list_layout.dart';
import '../../widgets/shared/filter/advanced_filter_drawer.dart';
import 'widgets/specialist_bento_stats.dart';
import 'widgets/specialist_filter_bar.dart';
import 'widgets/specialist_order_list.dart';
import '../../widgets/shared/form/app_buttons.dart';

class SpecialistDashboardPage extends ConsumerStatefulWidget {
  const SpecialistDashboardPage({super.key});

  @override
  ConsumerState<SpecialistDashboardPage> createState() =>
      _SpecialistDashboardPageState();
}

class _SpecialistDashboardPageState
    extends ConsumerState<SpecialistDashboardPage> {
  late final SpecialistDashboardCubit _cubit;
  bool _isDrawerRegistered = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SpecialistDashboardCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState.user?.uid != null) {
        _cubit.loadOrders(authState.user!.uid);
      }
    });
  }

  void _registerDrawer(WidgetRef ref) {
    if (_isDrawerRegistered) return;
    
    _isDrawerRegistered = true;
    Future.microtask(() {
      if (!mounted) return;
      ref.read(drawerProvider.notifier).update(
            endDrawer: BlocProvider.value(
              value: _cubit,
              child: BlocBuilder<SpecialistDashboardCubit, SpecialistDashboardState>(
                buildWhen: (p, c) => p.sortOrder != c.sortOrder || p.dateRangePreset != c.dateRangePreset,
                builder: (context, state) {
                  return AppAdvancedFilterDrawer(
                    currentSortOrder: state.sortOrder,
                    onSortOrderChanged: (sort) => _cubit.updateFilters(sortOrder: sort),
                    currentDateRange: state.dateRangePreset,
                    onDateRangeChanged: (range) => _cubit.updateFilters(dateRangePreset: range),
                    onApply: () {},
                    onClear: () => _cubit.updateFilters(
                      searchKeyword: '',
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
  void dispose() {
    _cubit.close();
    final drawer = ref.read(drawerProvider.notifier);
    // Clear global drawer when leaving the page
    Future.microtask(() {
      drawer.clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Register drawer once when cubit is ready
    _registerDrawer(ref);

    return BlocProvider.value(
      value: _cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<SpecialistDashboardCubit, SpecialistDashboardState>(
            listenWhen: (previous, current) => current.lastStartedOrderId != null,
            listener: (context, state) {
              if (state.lastStartedOrderId != null) {
                final orderId = state.lastStartedOrderId!;
                _cubit.clearNavigation();
                context.push('${AppRoutes.specialistAnalysis}/$orderId');
              }
            },
          ),
          BlocListener<NotificationCubit, NotificationState>(
            listener: (context, state) {
              if (state is NotificationActionRequested && (state.type == 'ORDER_ASSIGNED' || state.type == 'ORDER_REJECTED')) {
                _cubit.focusOrder(state.relatedId);
              }
            },
          ),
        ],
        child: MainListLayout(
          title: 'Bảng điều khiển',
          subtitle: 'Chào mừng trở lại, ${authState.displayName}',
          onRefresh: () async {
            if (authState.user?.uid != null) {
              _cubit.loadOrders(authState.user!.uid);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: BlocBuilder<SpecialistDashboardCubit, SpecialistDashboardState>(
              builder: (context, state) {
                if (state.status == SpecialistDashboardStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == SpecialistDashboardStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'Có lỗi xảy ra',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        AppPrimaryButton(
                          text: 'Thử lại',
                          onPressed: () {
                            if (authState.user?.uid != null) {
                              _cubit.loadOrders(authState.user!.uid);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SpecialistBentoStats(stats: state.stats),
                    const SizedBox(height: 32),
                    const SpecialistFilterBar(),
                    const SizedBox(height: 24),
                    SpecialistOrderList(
                      orders: state.filteredOrders,
                      focusedOrderId: state.focusedOrderId,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
