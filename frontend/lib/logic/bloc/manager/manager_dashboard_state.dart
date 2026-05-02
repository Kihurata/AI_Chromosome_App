import 'package:equatable/equatable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/entities/specialist.dart';

class ManagerStats extends Equatable {
  final int totalOrders;
  final int unassignedCount;
  final int ongoingCount;
  final int waitingApprovalCount;
  final int completedCount;

  const ManagerStats({
    this.totalOrders = 0,
    this.unassignedCount = 0,
    this.ongoingCount = 0,
    this.waitingApprovalCount = 0,
    this.completedCount = 0,
  });

  @override
  List<Object?> get props => [
        totalOrders,
        unassignedCount,
        ongoingCount,
        waitingApprovalCount,
        completedCount,
      ];
}

abstract class ManagerDashboardState extends Equatable {
  const ManagerDashboardState();

  @override
  List<Object?> get props => [];
}

class ManagerDashboardInitial extends ManagerDashboardState {}

class ManagerDashboardLoading extends ManagerDashboardState {}

class ManagerDashboardLoaded extends ManagerDashboardState {
  final List<TestOrder> allOrders;
  final List<TestOrder> filteredOrders;
  final List<Specialist> specialists;
  final ManagerStats stats;
  final String searchQuery;
  final TestOrderStatus? statusFilter;

  const ManagerDashboardLoaded({
    required this.allOrders,
    required this.filteredOrders,
    required this.specialists,
    required this.stats,
    this.searchQuery = '',
    this.statusFilter,
  });

  ManagerDashboardLoaded copyWith({
    List<TestOrder>? allOrders,
    List<TestOrder>? filteredOrders,
    List<Specialist>? specialists,
    ManagerStats? stats,
    String? searchQuery,
    TestOrderStatus? statusFilter,
  }) {
    return ManagerDashboardLoaded(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      specialists: specialists ?? this.specialists,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
        allOrders,
        filteredOrders,
        specialists,
        stats,
        searchQuery,
        statusFilter,
      ];
}

class ManagerDashboardError extends ManagerDashboardState {
  final String message;

  const ManagerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
