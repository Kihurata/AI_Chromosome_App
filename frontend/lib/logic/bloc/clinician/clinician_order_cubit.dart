import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/usecases/clinician/create_test_order.dart';
import '../../../domain/usecases/clinician/get_test_orders_by_patient.dart';
import '../../../domain/usecases/clinician/watch_test_orders_by_patient.dart';
import '../../../domain/usecases/test_order/watch_all_orders.dart';
import '../../../domain/usecases/sample/collect_physical_sample.dart';
import '../../../domain/entities/sample.dart';
import '../../../../core/models/filter_options.dart';
import 'clinician_order_state.dart';

@injectable
class ClinicianOrderCubit extends Cubit<ClinicianOrderState> {
  final CreateTestOrder createTestOrderUsecase;
  final GetTestOrdersByPatient getTestOrdersByPatientUsecase;
  final WatchTestOrdersByPatient watchTestOrdersByPatientUsecase;
  final CollectPhysicalSample collectPhysicalSampleUsecase;
  final WatchAllOrders watchAllOrdersUsecase;

  ClinicianOrderCubit({
    required this.createTestOrderUsecase,
    required this.getTestOrdersByPatientUsecase,
    required this.watchTestOrdersByPatientUsecase,
    required this.collectPhysicalSampleUsecase,
    required this.watchAllOrdersUsecase,
  }) : super(ClinicianOrderInitial());

  Future<void> loadAllOrders() async {
    emit(ClinicianOrderLoading());
    await for (final result in watchAllOrdersUsecase()) {
      if (isClosed) break;
      result.fold(
        (failure) => emit(ClinicianOrderError(failure.message)),
        (orders) {
          String currentSearch = '';
          AppSortOrder currentSort = AppSortOrder.newest;
          AppDateRangePreset currentDate = AppDateRangePreset.all;

          if (state is TestOrdersLoaded) {
            final s = state as TestOrdersLoaded;
            currentSearch = s.searchQuery;
            currentSort = s.sortOrder;
            currentDate = s.dateRangePreset;
          }

          final filtered = _applyFilters(
            orders,
            currentSearch,
            currentSort,
            currentDate,
          );

          emit(TestOrdersLoaded(
            allOrders: orders,
            filteredOrders: filtered,
            searchQuery: currentSearch,
            sortOrder: currentSort,
            dateRangePreset: currentDate,
          ));
        },
      );
    }
  }

  Future<void> loadTestOrders([String? patientId]) async {
    if (patientId == null || patientId.isEmpty) {
      return loadAllOrders();
    }
    emit(ClinicianOrderLoading());
    await for (final result in watchTestOrdersByPatientUsecase(patientId)) {
      if (isClosed) break;
      result.fold(
        (failure) => emit(ClinicianOrderError(failure.message)),
        (orders) {
          String currentSearch = '';
          AppSortOrder currentSort = AppSortOrder.newest;
          AppDateRangePreset currentDate = AppDateRangePreset.all;

          if (state is TestOrdersLoaded) {
            final s = state as TestOrdersLoaded;
            currentSearch = s.searchQuery;
            currentSort = s.sortOrder;
            currentDate = s.dateRangePreset;
          }

          final filtered = _applyFilters(
            orders,
            currentSearch,
            currentSort,
            currentDate,
          );

          emit(TestOrdersLoaded(
            allOrders: orders,
            filteredOrders: filtered,
            searchQuery: currentSearch,
            sortOrder: currentSort,
            dateRangePreset: currentDate,
          ));
        },
      );
    }
  }

  void updateFilters({
    String? searchQuery,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
  }) {
    if (state is! TestOrdersLoaded) return;
    final s = state as TestOrdersLoaded;

    final newQuery = searchQuery ?? s.searchQuery;
    final newSort = sortOrder ?? s.sortOrder;
    final newDate = dateRangePreset ?? s.dateRangePreset;

    final filtered = _applyFilters(
      s.allOrders,
      newQuery,
      newSort,
      newDate,
    );

    emit(s.copyWith(
      searchQuery: newQuery,
      sortOrder: newSort,
      dateRangePreset: newDate,
      filteredOrders: filtered,
    ));
  }

  void setSearchQuery(String query) => updateFilters(searchQuery: query);

  List<TestOrder> _applyFilters(
    List<TestOrder> orders,
    String query,
    AppSortOrder sortOrder,
    AppDateRangePreset dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = orders.where((order) {
      final matchesSearch = query.isEmpty ||
          order.id.toLowerCase().contains(query.toLowerCase());

      bool matchesDate = true;
      if (dateRange != AppDateRangePreset.all) {
        final orderDate = order.createdAt;
        if (dateRange == AppDateRangePreset.today) {
          matchesDate = orderDate.isAfter(today);
        } else if (dateRange == AppDateRangePreset.last7Days) {
          matchesDate = orderDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (dateRange == AppDateRangePreset.last30Days) {
          matchesDate = orderDate.isAfter(now.subtract(const Duration(days: 30)));
        }
      }

      return matchesSearch && matchesDate;
    }).toList();

    if (sortOrder == AppSortOrder.newest) {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return filtered;
  }

  Future<void> createOrder(TestOrder order) async {
    emit(ClinicianOrderLoading());
    final result = await createTestOrderUsecase(order);
    result.fold(
      (failure) => emit(ClinicianOrderError(failure.message)),
      (_) => emit(const ClinicianOrderSuccess('Tạo phiếu xét nghiệm thành công')),
    );
  }

  Future<void> submitOrderWithSample({
    required TestOrder order,
    required Sample sample,
  }) async {
    emit(ClinicianOrderLoading());
    
    // 1. Tạo Test Order
    final orderResult = await createTestOrderUsecase(order);
    
    await orderResult.fold(
      (failure) async => emit(ClinicianOrderError(failure.message)),
      (_) async {
        // 2. Tạo Sample
        final sampleResult = await collectPhysicalSampleUsecase(sample);
        sampleResult.fold(
          (failure) => emit(ClinicianOrderError('Đã tạo phiếu nhưng lỗi tạo mẫu: ${failure.message}')),
          (_) => emit(const ClinicianOrderSuccess('Tạo phiếu và mẫu xét nghiệm thành công')),
        );
      },
    );
  }
}
