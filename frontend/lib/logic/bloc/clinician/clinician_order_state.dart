import 'package:equatable/equatable.dart';
import '../../../domain/entities/test_order.dart';

abstract class ClinicianOrderState extends Equatable {
  const ClinicianOrderState();

  @override
  List<Object?> get props => [];
}

class ClinicianOrderInitial extends ClinicianOrderState {}

class ClinicianOrderLoading extends ClinicianOrderState {}

class TestOrdersLoaded extends ClinicianOrderState {
  final List<TestOrder> testOrders;

  const TestOrdersLoaded(this.testOrders);

  @override
  List<Object?> get props => [testOrders];
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
