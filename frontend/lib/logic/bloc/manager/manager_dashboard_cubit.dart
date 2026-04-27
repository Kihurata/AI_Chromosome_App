import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/test_order/assign_order_to_specialist.dart';
import '../../../domain/usecases/test_order/get_all_pending_orders.dart';
import 'manager_dashboard_state.dart';

class ManagerDashboardCubit extends Cubit<ManagerDashboardState> {
  final GetAllPendingOrders getAllPendingOrders;
  final AssignOrderToSpecialist assignOrderToSpecialist;

  ManagerDashboardCubit({
    required this.getAllPendingOrders,
    required this.assignOrderToSpecialist,
  }) : super(ManagerDashboardInitial());

  Future<void> fetchPendingOrders() async {
    emit(ManagerDashboardLoading());
    final result = await getAllPendingOrders();
    result.fold(
      (failure) => emit(ManagerDashboardError(failure.message)),
      (orders) => emit(ManagerDashboardLoaded(orders)),
    );
  }

  Future<void> assignSpecialist({
    required String orderId,
    required String specialistId,
  }) async {
    emit(ManagerDashboardLoading());
    final result = await assignOrderToSpecialist(
      orderId: orderId,
      specialistId: specialistId,
    );
    result.fold(
      (failure) => emit(ManagerDashboardError(failure.message)),
      (_) => fetchPendingOrders(),
    );
  }
}

