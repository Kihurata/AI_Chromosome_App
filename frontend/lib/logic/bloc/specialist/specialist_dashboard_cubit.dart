import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/usecases/specialist/watch_assigned_orders.dart';
import '../../../domain/usecases/specialist/update_order_status.dart';
import 'specialist_dashboard_state.dart';

@injectable
class SpecialistDashboardCubit extends Cubit<SpecialistDashboardState> {
  final WatchAssignedOrders _watchAssignedOrders;
  final UpdateOrderStatus _updateOrderStatus;
  StreamSubscription? _ordersSubscription;

  SpecialistDashboardCubit(
    this._watchAssignedOrders,
    this._updateOrderStatus,
  ) : super(SpecialistDashboardInitial());

  void initialize(String specialistId) {
    emit(SpecialistDashboardLoading());
    _ordersSubscription?.cancel();
    
    _ordersSubscription = _watchAssignedOrders(specialistId).listen(
      (result) {
        result.fold(
          (failure) => emit(SpecialistDashboardError(failure.message)),
          (orders) => _updateData(orders),
        );
      },
      onError: (error) => emit(SpecialistDashboardError(error.toString())),
    );
  }

  void _updateData(List<TestOrder> allOrders) {
    final stats = _calculateStats(allOrders);
    
    if (state is SpecialistDashboardLoaded) {
      final currentState = state as SpecialistDashboardLoaded;
      final filtered = _applyFilters(allOrders, currentState.searchQuery, currentState.statusFilter);
      emit(currentState.copyWith(
        allOrders: allOrders,
        filteredOrders: filtered,
        stats: stats,
      ));
    } else {
      emit(SpecialistDashboardLoaded(
        allOrders: allOrders,
        filteredOrders: allOrders,
        stats: stats,
      ));
    }
  }

  void setSearch(String query) {
    if (state is! SpecialistDashboardLoaded) return;
    final currentState = state as SpecialistDashboardLoaded;
    final filtered = _applyFilters(currentState.allOrders, query, currentState.statusFilter);
    emit(currentState.copyWith(searchQuery: query, filteredOrders: filtered));
  }

  void setStatusFilter(TestOrderStatus? status) {
    if (state is! SpecialistDashboardLoaded) return;
    final currentState = state as SpecialistDashboardLoaded;
    final filtered = _applyFilters(currentState.allOrders, currentState.searchQuery, status);
    emit(currentState.copyWith(statusFilter: status, filteredOrders: filtered));
  }

  List<TestOrder> _applyFilters(List<TestOrder> orders, String query, TestOrderStatus? status) {
    return orders.where((order) {
      final matchesQuery = query.isEmpty || 
          order.patientName.toLowerCase().contains(query.toLowerCase()) ||
          order.patientCode.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = status == null || order.status == status;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  SpecialistStats _calculateStats(List<TestOrder> orders) {
    int pending = 0;
    int analyzing = 0;
    int completed = 0;

    for (var order in orders) {
      switch (order.status) {
        case TestOrderStatus.pending:
          pending++;
          break;
        case TestOrderStatus.analyzing:
          analyzing++;
          break;
        case TestOrderStatus.completed:
          completed++;
          break;
        default:
          break;
      }
    }

    return SpecialistStats(
      total: orders.length,
      pending: pending,
      analyzing: analyzing,
      completed: completed,
    );
  }

  Future<void> startAnalysis(String orderId) async {
    final result = await _updateOrderStatus(orderId, TestOrderStatus.analyzing);
    result.fold(
      (failure) => emit(SpecialistDashboardError(failure.message)),
      (_) => null, // Stream will update automatically
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
