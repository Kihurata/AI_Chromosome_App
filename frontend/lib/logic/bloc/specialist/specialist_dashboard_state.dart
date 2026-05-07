import 'package:equatable/equatable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/entities/specialist_stats.dart';
import '../../../../core/models/filter_options.dart';

enum SpecialistDashboardStatus { initial, loading, success, error }

class SpecialistDashboardState extends Equatable {
  final SpecialistDashboardStatus status;
  final List<TestOrder> allOrders;
  final List<TestOrder> filteredOrders;
  final SpecialistStats stats;
  final String searchKeyword;
  final TestOrderStatus? statusFilter;
  final AppSortOrder sortOrder;
  final AppDateRangePreset dateRangePreset;
  final String? errorMessage;
  final String? lastStartedOrderId;
  final String? focusedOrderId;

  const SpecialistDashboardState({
    this.status = SpecialistDashboardStatus.initial,
    this.allOrders = const [],
    this.filteredOrders = const [],
    this.stats = const SpecialistStats(),
    this.searchKeyword = '',
    this.statusFilter,
    this.sortOrder = AppSortOrder.newest,
    this.dateRangePreset = AppDateRangePreset.all,
    this.errorMessage,
    this.lastStartedOrderId,
    this.focusedOrderId,
  });

  SpecialistDashboardState copyWith({
    SpecialistDashboardStatus? status,
    List<TestOrder>? allOrders,
    List<TestOrder>? filteredOrders,
    SpecialistStats? stats,
    String? searchKeyword,
    TestOrderStatus? statusFilter,
    bool clearStatusFilter = false,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
    String? errorMessage,
    String? lastStartedOrderId,
    bool clearLastStartedOrderId = false,
    String? focusedOrderId,
  }) {
    return SpecialistDashboardState(
      status: status ?? this.status,
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      stats: stats ?? this.stats,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      sortOrder: sortOrder ?? this.sortOrder,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
      errorMessage: errorMessage ?? this.errorMessage,
      lastStartedOrderId: clearLastStartedOrderId ? null : (lastStartedOrderId ?? this.lastStartedOrderId),
      focusedOrderId: focusedOrderId ?? this.focusedOrderId,
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
        sortOrder,
        dateRangePreset,
        errorMessage,
        lastStartedOrderId,
        focusedOrderId,
      ];
}
