import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/entities/specialist_stats.dart';
import '../../../domain/usecases/specialist/watch_assigned_orders.dart';
import '../../../domain/usecases/specialist/update_order_status.dart';
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
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: SpecialistDashboardStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void setSearchKeyword(String keyword) {
    final filtered = _applyFilters(state.allOrders, keyword, state.statusFilter);
    emit(state.copyWith(
      searchKeyword: keyword,
      filteredOrders: filtered,
      focusedOrderId: null, // Clear focus on manual search
    ));
  }

  void focusOrder(String orderId) {
    // Auto search by order ID
    final filtered = _applyFilters(state.allOrders, orderId, null);
    
    emit(state.copyWith(
      searchKeyword: orderId,
      statusFilter: null, // Clear status filter to ensure the order is visible
      filteredOrders: filtered,
      focusedOrderId: orderId,
    ));

    // Clear focus highlight after 5 seconds but keep the search result
    Future.delayed(const Duration(seconds: 5), () {
      if (!isClosed && state.focusedOrderId == orderId) {
        emit(state.copyWith(focusedOrderId: null));
      }
    });
  }

  void setStatusFilter(TestOrderStatus? status) {
    final filtered = _applyFilters(state.allOrders, state.searchKeyword, status);
    emit(state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
      filteredOrders: filtered,
      focusedOrderId: null, // Clear focus on manual filter
    ));
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
  ) {
    return orders.where((order) {
      final matchesSearch = keyword.isEmpty || 
          order.patientName.toLowerCase().contains(keyword.toLowerCase()) ||
          order.patientCode.toLowerCase().contains(keyword.toLowerCase()) ||
          order.id.toLowerCase().contains(keyword.toLowerCase()); // Added ID search
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
        case TestOrderStatus.culturing: // gộp nuôi cấy vào "Chờ xử lý"
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
