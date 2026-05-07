import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/entities/specialist.dart';
import '../../../domain/usecases/test_order/watch_all_orders.dart';
import '../../../domain/usecases/test_order/assign_order_to_specialist.dart';
import '../../../domain/usecases/test_order/approve_karyotype_result.dart';
import '../../../domain/usecases/test_order/reject_karyotype_result.dart';
import '../../../domain/usecases/specialist/get_specialists.dart';
import 'manager_dashboard_state.dart';

@injectable
class ManagerDashboardCubit extends Cubit<ManagerDashboardState> {
  final WatchAllOrders _watchAllOrders;
  final AssignOrderToSpecialist _assignOrderToSpecialist;
  final ApproveKaryotypeResult _approveKaryotypeResult;
  final RejectKaryotypeResult _rejectKaryotypeResult;
  final GetSpecialists _getSpecialists;

  StreamSubscription? _ordersSubscription;

  ManagerDashboardCubit(
    this._watchAllOrders,
    this._assignOrderToSpecialist,
    this._approveKaryotypeResult,
    this._rejectKaryotypeResult,
    this._getSpecialists,
  ) : super(ManagerDashboardInitial());

  void initialize() async {
    emit(ManagerDashboardLoading());
    
    // Fetch specialists once (or could be streamed if needed)
    final specialistsResult = await _getSpecialists();
    List<Specialist> specialists = [];
    specialistsResult.fold(
      (failure) => emit(ManagerDashboardError(failure.message)),
      (list) => specialists = list,
    );

    if (state is ManagerDashboardError) return;

    _ordersSubscription?.cancel();
    _ordersSubscription = _watchAllOrders().listen(
      (result) {
        result.fold(
          (failure) => emit(ManagerDashboardError(failure.message)),
          (orders) => _updateData(orders, specialists),
        );
      },
      onError: (error) => emit(ManagerDashboardError(error.toString())),
    );
  }

  void _updateData(List<TestOrder> allOrders, List<Specialist> baseSpecialists) {
    // 1. Calculate stats
    final stats = _calculateStats(allOrders);

    // 2. Update specialists with active workload
    final updatedSpecialists = baseSpecialists.map((s) {
      final workload = allOrders.where((o) => 
        o.specialistId == s.id && 
        (o.status == TestOrderStatus.analyzing || o.status == TestOrderStatus.waitingApproval)
      ).length;
      return s.copyWith(activeWorkload: workload);
    }).toList();

    // 3. Apply sorting: Unassigned first, then by date
    final sortedOrders = List<TestOrder>.from(allOrders)..sort((a, b) {
      if (a.status == TestOrderStatus.pending && b.status != TestOrderStatus.pending) return -1;
      if (a.status != TestOrderStatus.pending && b.status == TestOrderStatus.pending) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    if (state is ManagerDashboardLoaded) {
      final currentState = state as ManagerDashboardLoaded;
      final filtered = _applyFilters(sortedOrders, currentState.searchQuery, currentState.statusFilter);
      emit(currentState.copyWith(
        allOrders: sortedOrders,
        filteredOrders: filtered,
        specialists: updatedSpecialists,
        stats: stats,
      ));
    } else {
      emit(ManagerDashboardLoaded(
        allOrders: sortedOrders,
        filteredOrders: sortedOrders,
        specialists: updatedSpecialists,
        stats: stats,
      ));
    }
  }

  ManagerStats _calculateStats(List<TestOrder> orders) {
    int unassigned = 0;
    int ongoing = 0;
    int waiting = 0;
    int completed = 0;

    for (var order in orders) {
      switch (order.status) {
        case TestOrderStatus.pending:
          unassigned++;
          break;
        case TestOrderStatus.analyzing:
          ongoing++;
          break;
        case TestOrderStatus.waitingApproval:
          waiting++;
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
      waitingApprovalCount: waiting,
      completedCount: completed,
    );
  }

  void setSearch(String query) {
    if (state is! ManagerDashboardLoaded) return;
    final currentState = state as ManagerDashboardLoaded;
    final filtered = _applyFilters(currentState.allOrders, query, currentState.statusFilter);
    emit(currentState.copyWith(
      searchQuery: query, 
      filteredOrders: filtered,
      focusedOrderId: null, // Clear focus when user types manually
    ));
  }

  void focusOrder(String orderId) {
    if (state is! ManagerDashboardLoaded) return;
    final currentState = state as ManagerDashboardLoaded;
    
    // Auto search by order ID
    final filtered = _applyFilters(currentState.allOrders, orderId, null);
    
    emit(currentState.copyWith(
      searchQuery: orderId,
      statusFilter: null, // Clear status filter to ensure the order is visible
      filteredOrders: filtered,
      focusedOrderId: orderId,
    ));

    // Clear focus highlight after 5 seconds but keep the search result
    Future.delayed(const Duration(seconds: 5), () {
      if (state is ManagerDashboardLoaded) {
        final nowState = state as ManagerDashboardLoaded;
        if (nowState.focusedOrderId == orderId) {
          emit(nowState.copyWith(focusedOrderId: null));
        }
      }
    });
  }

  void setStatusFilter(TestOrderStatus? status) {
    if (state is! ManagerDashboardLoaded) return;
    final currentState = state as ManagerDashboardLoaded;
    final filtered = _applyFilters(currentState.allOrders, currentState.searchQuery, status);
    emit(currentState.copyWith(statusFilter: status, filteredOrders: filtered, focusedOrderId: null));
  }

  List<TestOrder> _applyFilters(List<TestOrder> orders, String query, TestOrderStatus? status) {
    return orders.where((order) {
      final matchesQuery = query.isEmpty || 
          order.patientName.toLowerCase().contains(query.toLowerCase()) ||
          order.patientCode.toLowerCase().contains(query.toLowerCase()) ||
          order.id.toLowerCase().contains(query.toLowerCase()); // Added ID search
      final matchesStatus = status == null || order.status == status;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  Future<void> assignSpecialist({
    required String orderId,
    required String specialistId,
  }) async {
    final result = await _assignOrderToSpecialist(
      orderId: orderId,
      specialistId: specialistId,
    );
    result.fold(
      (failure) => emit(ManagerDashboardError(failure.message)),
      (_) => null, // Stream will update
    );
  }

  Future<void> approveOrder(String orderId) async {
    final result = await _approveKaryotypeResult(orderId);
    result.fold(
      (failure) => emit(ManagerDashboardError(failure.message)),
      (_) => null, // Stream will update
    );
  }

  Future<void> rejectOrder(String orderId, String comment) async {
    final result = await _rejectKaryotypeResult(orderId, comment);
    result.fold(
      (failure) => emit(ManagerDashboardError(failure.message)),
      (_) => null, // Stream will update
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
