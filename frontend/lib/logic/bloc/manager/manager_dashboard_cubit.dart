import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../core/models/filter_options.dart';
import 'manager_dashboard_state.dart';

import '../../../domain/usecases/test_order/watch_all_orders.dart';
import '../../../domain/usecases/specialist/get_specialists.dart';
import '../../../domain/usecases/test_order/assign_order_to_specialist.dart';
import '../../../domain/entities/specialist.dart';

@injectable
class ManagerDashboardCubit extends Cubit<ManagerDashboardState> {
  final WatchAllOrders _watchAllOrdersUsecase;
  final GetSpecialists _getSpecialistsUsecase;
  final AssignOrderToSpecialist _assignOrderToSpecialistUsecase;

  ManagerDashboardCubit(
    this._watchAllOrdersUsecase,
    this._getSpecialistsUsecase,
    this._assignOrderToSpecialistUsecase,
  ) : super(ManagerDashboardInitial());

  Future<void> loadDashboard() async {
    emit(ManagerDashboardLoading());

    try {
      final specialistsResult = await _getSpecialistsUsecase();
      final specialists = specialistsResult.fold((_) => <Specialist>[], (s) => s);

      await for (final result in _watchAllOrdersUsecase()) {
        if (isClosed) break;

        result.fold(
          (failure) => emit(ManagerDashboardError(failure.message)),
          (orders) {
            final stats = _calculateStats(orders);
            
            // Re-apply existing filters if we were already in Loaded state
            String currentSearch = '';
            TestOrderStatus? currentStatus;
            AppSortOrder currentSort = AppSortOrder.newest;
            AppDateRangePreset currentDate = AppDateRangePreset.all;

            if (state is ManagerDashboardLoaded) {
              final s = state as ManagerDashboardLoaded;
              currentSearch = s.searchQuery;
              currentStatus = s.statusFilter;
              currentSort = s.sortOrder;
              currentDate = s.dateRangePreset;
            }

            final filtered = _applyFilters(
              orders,
              currentSearch,
              currentStatus,
              currentSort,
              currentDate,
            );

            emit(ManagerDashboardLoaded(
              allOrders: orders,
              filteredOrders: filtered,
              specialists: specialists,
              stats: stats,
              searchQuery: currentSearch,
              statusFilter: currentStatus,
              sortOrder: currentSort,
              dateRangePreset: currentDate,
            ));
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(ManagerDashboardError(e.toString()));
      }
    }
  }

  void updateFilters({
    String? searchQuery,
    TestOrderStatus? statusFilter,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
    bool clearStatusFilter = false,
  }) {
    if (state is! ManagerDashboardLoaded) return;
    final s = state as ManagerDashboardLoaded;

    final newQuery = searchQuery ?? s.searchQuery;
    final newStatus = clearStatusFilter ? null : (statusFilter ?? s.statusFilter);
    final newSort = sortOrder ?? s.sortOrder;
    final newDate = dateRangePreset ?? s.dateRangePreset;

    final filtered = _applyFilters(
      s.allOrders,
      newQuery,
      newStatus,
      newSort,
      newDate,
    );

    emit(s.copyWith(
      searchQuery: newQuery,
      statusFilter: newStatus,
      clearStatusFilter: clearStatusFilter,
      sortOrder: newSort,
      dateRangePreset: newDate,
      filteredOrders: filtered,
      focusedOrderId: null,
    ));
  }

  void setSearchQuery(String query) => updateFilters(searchQuery: query);

  void setStatusFilter(TestOrderStatus? status) =>
      updateFilters(statusFilter: status, clearStatusFilter: status == null);

  void focusOrder(String orderId) {
    if (state is! ManagerDashboardLoaded) return;
    final s = state as ManagerDashboardLoaded;

    final filtered = _applyFilters(
      s.allOrders,
      orderId,
      null,
      s.sortOrder,
      AppDateRangePreset.all,
    );

    emit(s.copyWith(
      searchQuery: orderId,
      statusFilter: null,
      clearStatusFilter: true,
      dateRangePreset: AppDateRangePreset.all,
      filteredOrders: filtered,
      focusedOrderId: orderId,
    ));

    Future.delayed(const Duration(seconds: 5), () {
      if (!isClosed && state is ManagerDashboardLoaded) {
        final current = state as ManagerDashboardLoaded;
        if (current.focusedOrderId == orderId) {
          emit(current.copyWith(focusedOrderId: null));
        }
      }
    });
  }

  List<TestOrder> _applyFilters(
    List<TestOrder> orders,
    String query,
    TestOrderStatus? status,
    AppSortOrder sortOrder,
    AppDateRangePreset dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = orders.where((order) {
      final matchesSearch = query.isEmpty ||
          order.patientName.toLowerCase().contains(query.toLowerCase()) ||
          order.patientCode.toLowerCase().contains(query.toLowerCase()) ||
          order.id.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = status == null || order.status == status;

      bool matchesDate = true;
      if (dateRange != AppDateRangePreset.all) {
        final orderDate = order.createdAt;
        if (dateRange == AppDateRangePreset.today) {
          matchesDate = orderDate.isAfter(today);
        } else if (dateRange == AppDateRangePreset.last7Days) {
          matchesDate = orderDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (dateRange == AppDateRangePreset.last30Days) {
          matchesDate = orderDate.isAfter(now.subtract(const Duration(days: 30)));
        }
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    if (sortOrder == AppSortOrder.newest) {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return filtered;
  }

  ManagerStats _calculateStats(List<TestOrder> orders) {
    int unassigned = 0;
    int ongoing = 0;
    int waitingApproval = 0;
    int completed = 0;

    for (final order in orders) {
      if (order.specialistId == null && order.status != TestOrderStatus.completed && order.status != TestOrderStatus.rejected) {
        unassigned++;
      }
      
      switch (order.status) {
        case TestOrderStatus.pending:
        case TestOrderStatus.culturing:
        case TestOrderStatus.analyzing:
          ongoing++;
          break;
        case TestOrderStatus.waitingApproval:
          waitingApproval++;
          break;
        case TestOrderStatus.completed:
          completed++;
          break;
        default:
          break;
      }
    }

    return ManagerStats(
      totalOrders: orders.length,
      unassignedCount: unassigned,
      ongoingCount: ongoing,
      waitingApprovalCount: waitingApproval,
      completedCount: completed,
    );
  }

  Future<void> assignOrder({required String orderId, required String specialistId}) async {
    final result = await _assignOrderToSpecialistUsecase(orderId: orderId, specialistId: specialistId);
    if (result.isLeft()) {
      // In a real app, we might emit an error state or show a snackbar
    }
  }
}
