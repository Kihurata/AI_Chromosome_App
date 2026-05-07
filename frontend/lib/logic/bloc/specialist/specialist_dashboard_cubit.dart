import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/entities/specialist_stats.dart';
import '../../../domain/usecases/specialist/watch_assigned_orders.dart';
import '../../../domain/usecases/specialist/update_order_status.dart';
import '../../../../core/models/filter_options.dart';
import 'specialist_dashboard_state.dart';

@injectable
class SpecialistDashboardCubit extends Cubit<SpecialistDashboardState> {
  final WatchAssignedOrders watchOrdersUsecase;
  final UpdateOrderStatus updateStatusUsecase;

  SpecialistDashboardCubit({
    required this.watchOrdersUsecase,
    required this.updateStatusUsecase,
  }) : super(const SpecialistDashboardState());

  Future<void> loadOrders(String specialistId) async {
    emit(state.copyWith(status: SpecialistDashboardStatus.loading));

    try {
      await for (final result in watchOrdersUsecase(specialistId)) {
        if (isClosed) break;

        result.fold(
          (failure) => emit(state.copyWith(
            status: SpecialistDashboardStatus.error,
            errorMessage: failure.message,
          )),
          (orders) {
            final stats = _calculateStats(orders);
            final filtered = _applyFilters(
              orders,
              state.searchKeyword,
              state.statusFilter,
              state.sortOrder,
              state.dateRangePreset,
            );
            emit(state.copyWith(
              status: SpecialistDashboardStatus.success,
              allOrders: orders,
              filteredOrders: filtered,
              stats: stats,
            ));
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: SpecialistDashboardStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void updateFilters({
    String? searchKeyword,
    TestOrderStatus? statusFilter,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
    bool clearStatusFilter = false,
  }) {
    final newKeyword = searchKeyword ?? state.searchKeyword;
    final newStatus = clearStatusFilter ? null : (statusFilter ?? state.statusFilter);
    final newSort = sortOrder ?? state.sortOrder;
    final newDate = dateRangePreset ?? state.dateRangePreset;

    final filtered = _applyFilters(
      state.allOrders,
      newKeyword,
      newStatus,
      newSort,
      newDate,
    );

    emit(state.copyWith(
      searchKeyword: newKeyword,
      statusFilter: newStatus,
      clearStatusFilter: clearStatusFilter,
      sortOrder: newSort,
      dateRangePreset: newDate,
      filteredOrders: filtered,
      focusedOrderId: null,
    ));
  }

  void setSearchKeyword(String keyword) => updateFilters(searchKeyword: keyword);

  void setStatusFilter(TestOrderStatus? status) =>
      updateFilters(statusFilter: status, clearStatusFilter: status == null);

  void focusOrder(String orderId) {
    // Auto search by order ID
    final filtered = _applyFilters(
      state.allOrders,
      orderId,
      null,
      state.sortOrder,
      AppDateRangePreset.all,
    );
    
    emit(state.copyWith(
      searchKeyword: orderId,
      statusFilter: null,
      clearStatusFilter: true,
      dateRangePreset: AppDateRangePreset.all,
      filteredOrders: filtered,
      focusedOrderId: orderId,
    ));

    Future.delayed(const Duration(seconds: 5), () {
      if (!isClosed && state.focusedOrderId == orderId) {
        emit(state.copyWith(focusedOrderId: null));
      }
    });
  }

  Future<void> startOrderAnalysis(String orderId) async {
    final result = await updateStatusUsecase(orderId, TestOrderStatus.analyzing);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SpecialistDashboardStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(lastStartedOrderId: orderId)),
    );
  }

  void clearNavigation() {
    emit(state.copyWith(clearLastStartedOrderId: true));
  }

  List<TestOrder> _applyFilters(
    List<TestOrder> orders,
    String keyword,
    TestOrderStatus? status,
    AppSortOrder sortOrder,
    AppDateRangePreset dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = orders.where((order) {
      final matchesSearch = keyword.isEmpty ||
          order.patientName.toLowerCase().contains(keyword.toLowerCase()) ||
          order.patientCode.toLowerCase().contains(keyword.toLowerCase()) ||
          order.id.toLowerCase().contains(keyword.toLowerCase());
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

  SpecialistStats _calculateStats(List<TestOrder> orders) {
    int pending = 0;
    int analyzing = 0;
    int waitingApproval = 0;
    int completed = 0;

    for (final order in orders) {
      switch (order.status) {
        case TestOrderStatus.pending:
        case TestOrderStatus.culturing:
          pending++;
          break;
        case TestOrderStatus.analyzing:
          analyzing++;
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

    return SpecialistStats(
      pending: pending,
      analyzing: analyzing,
      waitingApproval: waitingApproval,
      completed: completed,
    );
  }
}
