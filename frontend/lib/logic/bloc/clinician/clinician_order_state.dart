import 'package:equatable/equatable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../../core/models/filter_options.dart';

abstract class ClinicianOrderState extends Equatable {
  const ClinicianOrderState();

  @override
  List<Object?> get props => [];
}

class ClinicianOrderInitial extends ClinicianOrderState {}

class ClinicianOrderLoading extends ClinicianOrderState {}

class TestOrdersLoaded extends ClinicianOrderState {
  final List<TestOrder> allOrders;
  final List<TestOrder> filteredOrders;
  final String searchQuery;
  final AppSortOrder sortOrder;
  final AppDateRangePreset dateRangePreset;

  const TestOrdersLoaded({
    required this.allOrders,
    required this.filteredOrders,
    this.searchQuery = '',
    this.sortOrder = AppSortOrder.newest,
    this.dateRangePreset = AppDateRangePreset.all,
  });

  TestOrdersLoaded copyWith({
    List<TestOrder>? allOrders,
    List<TestOrder>? filteredOrders,
    String? searchQuery,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
  }) {
    return TestOrdersLoaded(
      allOrders: allOrders ?? this.allOrders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
    );
  }

  @override
  List<Object?> get props => [
        allOrders,
        filteredOrders,
        searchQuery,
        sortOrder,
        dateRangePreset,
      ];
}

class ClinicianOrderSuccess extends ClinicianOrderState {
  final String message;

  const ClinicianOrderSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ClinicianOrderError extends ClinicianOrderState {
  final String message;

  const ClinicianOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
