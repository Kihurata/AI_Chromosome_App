import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/entities/specialist_stats.dart';
import '../../../domain/usecases/specialist/watch_assigned_orders.dart';
import '../../../domain/usecases/specialist/update_order_status.dart';
import 'specialist_dashboard_state.dart';

class SpecialistDashboardCubit extends Cubit<SpecialistDashboardState> {
  final WatchAssignedOrders watchOrdersUsecase;
  final UpdateOrderStatus updateStatusUsecase;

  SpecialistDashboardCubit({
    required this.watchOrdersUsecase,
    required this.updateStatusUsecase,
  }) : super(const SpecialistDashboardState());

  Future<void> loadOrders(String specialistId) async {
    emit(state.copyWith(status: SpecialistDashboardStatus.loading));

    // Following Critical Pattern: await for instead of emit.forEach
    await for (final result in watchOrdersUsecase(specialistId)) {
      if (isClosed) break;

      result.fold(
        (failure) => emit(state.copyWith(
          status: SpecialistDashboardStatus.error,
          errorMessage: failure.message,
        )),
        (orders) {
          final stats = _calculateStats(orders);
          final filtered = _applyFilters(orders, state.searchKeyword, state.statusFilter);
          emit(state.copyWith(
            status: SpecialistDashboardStatus.success,
            allOrders: orders,
            filteredOrders: filtered,
            stats: stats,
          ));
        },
      );
    }
  }

  void setSearchKeyword(String keyword) {
    final filtered = _applyFilters(state.allOrders, keyword, state.statusFilter);
    emit(state.copyWith(
      searchKeyword: keyword,
      filteredOrders: filtered,
    ));
  }

  void setStatusFilter(TestOrderStatus? status) {
    final filtered = _applyFilters(state.allOrders, state.searchKeyword, status);
    emit(state.copyWith(
      statusFilter: status,
      filteredOrders: filtered,
    ));
  }

  Future<void> startOrderAnalysis(String orderId) async {
    // Optimistic UI update or just wait for Stream?
    // Usually wait for Stream is safer in event-driven.
    final result = await updateStatusUsecase(orderId, TestOrderStatus.analyzing);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SpecialistDashboardStatus.error,
        errorMessage: failure.message,
      )),
      (_) => null, // Success will be reflected by the Stream
    );
  }

  List<TestOrder> _applyFilters(
    List<TestOrder> orders,
    String keyword,
    TestOrderStatus? status,
  ) {
    return orders.where((order) {
      final matchesSearch = order.patientName.toLowerCase().contains(keyword.toLowerCase()) ||
          order.patientCode.toLowerCase().contains(keyword.toLowerCase());
      final matchesStatus = status == null || order.status == status;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  SpecialistStats _calculateStats(List<TestOrder> orders) {
    int pending = 0;
    int analyzing = 0;
    int waitingApproval = 0;
    int completed = 0;

    for (final order in orders) {
      switch (order.status) {
        case TestOrderStatus.pending:
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
