import 'package:equatable/equatable.dart';
import '../../../domain/entities/test_order.dart';

abstract class ManagerDashboardState extends Equatable {
  const ManagerDashboardState();

  @override
  List<Object?> get props => [];
}

class ManagerDashboardInitial extends ManagerDashboardState {}

class ManagerDashboardLoading extends ManagerDashboardState {}

class ManagerDashboardLoaded extends ManagerDashboardState {
  final List<TestOrder> pendingOrders;

  const ManagerDashboardLoaded(this.pendingOrders);

  @override
  List<Object?> get props => [pendingOrders];
}

class ManagerDashboardError extends ManagerDashboardState {
  final String message;

  const ManagerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
