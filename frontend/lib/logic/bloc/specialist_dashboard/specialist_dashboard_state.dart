import 'package:equatable/equatable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/entities/specialist_stats.dart';

enum SpecialistDashboardStatus { initial, loading, success, error }

class SpecialistDashboardState extends Equatable {
  final SpecialistDashboardStatus status;
  final List<TestOrder> allOrders;
  final List<TestOrder> filteredOrders;
  final SpecialistStats stats;
  final String searchKeyword;
  final TestOrderStatus? statusFilter;
  final String? errorMessage;
  final String? lastStartedOrderId;

  const SpecialistDashboardState({
    this.status = SpecialistDashboardStatus.initial,
    this.allOrders = const [],
    this.filteredOrders = const [],
    this.stats = const SpecialistStats(),
    this.searchKeyword = '',
    this.statusFilter,
    this.errorMessage,
    this.lastStartedOrderId,
  });

  SpecialistDashboardState copyWith({
    SpecialistDashboardStatus? status,
    List<TestOrder>? allOrders,
    List<TestOrder>? filteredOrders,
    SpecialistStats? stats,
    String? searchKeyword,
    TestOrderStatus? statusFilter,
    String? errorMessage,
    String? lastStartedOrderId,
  }) {
    return SpecialistDashboardState(
      status: status ?? this.status,
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      stats: stats ?? this.stats,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: errorMessage ?? this.errorMessage,
      lastStartedOrderId: lastStartedOrderId ?? this.lastStartedOrderId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allOrders,
        filteredOrders,
        stats,
        searchKeyword,
        statusFilter,
        errorMessage,
        lastStartedOrderId,
      ];
}
