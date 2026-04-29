import 'package:equatable/equatable.dart';
import '../../../domain/entities/test_order.dart';

class SpecialistStats extends Equatable {
  final int total;
  final int pending;
  final int analyzing;
  final int completed;

  const SpecialistStats({
    this.total = 0,
    this.pending = 0,
    this.analyzing = 0,
    this.completed = 0,
  });

  @override
  List<Object?> get props => [total, pending, analyzing, completed];
}

abstract class SpecialistDashboardState extends Equatable {
  const SpecialistDashboardState();

  @override
  List<Object?> get props => [];
}

class SpecialistDashboardInitial extends SpecialistDashboardState {}

class SpecialistDashboardLoading extends SpecialistDashboardState {}

class SpecialistDashboardLoaded extends SpecialistDashboardState {
  final List<TestOrder> allOrders;
  final List<TestOrder> filteredOrders;
  final SpecialistStats stats;
  final String searchQuery;
  final TestOrderStatus? statusFilter;

  const SpecialistDashboardLoaded({
    required this.allOrders,
    required this.filteredOrders,
    required this.stats,
    this.searchQuery = '',
    this.statusFilter,
  });

  @override
  List<Object?> get props => [allOrders, filteredOrders, stats, searchQuery, statusFilter];

  SpecialistDashboardLoaded copyWith({
    List<TestOrder>? allOrders,
    List<TestOrder>? filteredOrders,
    SpecialistStats? stats,
    String? searchQuery,
    TestOrderStatus? statusFilter,
  }) {
    return SpecialistDashboardLoaded(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class SpecialistDashboardError extends SpecialistDashboardState {
  final String message;
  const SpecialistDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
