import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../domain/repositories/sample_repository.dart';
import '../../../../domain/usecases/specialist/update_order_status.dart';
import '../../../../core/models/filter_options.dart';
import 'sample_management_state.dart';

@injectable
class SampleManagementCubit extends Cubit<SampleManagementState> {
  final SampleRepository _repository;
  final UpdateOrderStatus _updateOrderStatus;

  SampleManagementCubit(
    this._repository,
    this._updateOrderStatus,
  ) : super(const SampleManagementState());

  Future<void> loadSamples() async {
    emit(state.copyWith(status: SampleManagementStatus.loading));
    
    try {
      await for (final result in _repository.watchSamples()) {
        if (isClosed) break;

        result.fold(
          (failure) => emit(state.copyWith(
            status: SampleManagementStatus.error,
            errorMessage: failure.message,
          )),
          (samples) {
            final filtered = _applyFilters(
              samples,
              state.searchKeyword,
              state.filterStatus,
              state.sortOrder,
              state.dateRangePreset,
            );
            emit(state.copyWith(
              status: SampleManagementStatus.loaded,
              allSamples: samples,
              filteredSamples: filtered,
            ));
          },
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: SampleManagementStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  void updateFilters({
    String? searchKeyword,
    SampleStatus? statusFilter,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
    bool clearStatusFilter = false,
  }) {
    final newKeyword = searchKeyword ?? state.searchKeyword;
    final newStatus = clearStatusFilter ? null : (statusFilter ?? state.filterStatus);
    final newSort = sortOrder ?? state.sortOrder;
    final newDate = dateRangePreset ?? state.dateRangePreset;

    final filtered = _applyFilters(
      state.allSamples,
      newKeyword,
      newStatus,
      newSort,
      newDate,
    );

    emit(state.copyWith(
      searchKeyword: newKeyword,
      filterStatus: newStatus,
      clearStatusFilter: clearStatusFilter,
      sortOrder: newSort,
      dateRangePreset: newDate,
      filteredSamples: filtered,
    ));
  }

  void setSearchKeyword(String keyword) => updateFilters(searchKeyword: keyword);

  void setFilter(SampleStatus? status) =>
      updateFilters(statusFilter: status, clearStatusFilter: status == null);

  List<Sample> _applyFilters(
    List<Sample> samples,
    String keyword,
    SampleStatus? status,
    AppSortOrder sortOrder,
    AppDateRangePreset dateRange,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = samples.where((sample) {
      final matchesSearch = keyword.isEmpty ||
          sample.patientName.toLowerCase().contains(keyword.toLowerCase()) ||
          sample.patientCode.toLowerCase().contains(keyword.toLowerCase()) ||
          sample.id.toLowerCase().contains(keyword.toLowerCase());
      final matchesStatus = status == null || sample.status == status;

      bool matchesDate = true;
      if (dateRange != AppDateRangePreset.all) {
        final sampleDate = sample.collectedAt;
        if (dateRange == AppDateRangePreset.today) {
          matchesDate = sampleDate.isAfter(today);
        } else if (dateRange == AppDateRangePreset.last7Days) {
          matchesDate = sampleDate.isAfter(now.subtract(const Duration(days: 7)));
        } else if (dateRange == AppDateRangePreset.last30Days) {
          matchesDate = sampleDate.isAfter(now.subtract(const Duration(days: 30)));
        }
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    if (sortOrder == AppSortOrder.newest) {
      filtered.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
    } else {
      filtered.sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
    }

    return filtered;
  }

  Future<void> updateStatus(String sampleId, SampleStatus status) async {
    final result = await _repository.updateSampleStatus(sampleId, status);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SampleManagementStatus.error,
        errorMessage: failure.message,
      )),
      (_) => null,
    );
  }

  Future<void> startAnalysis(String orderId) async {
    final result = await _updateOrderStatus(orderId, TestOrderStatus.analyzing);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SampleManagementStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(lastStartedOrderId: orderId)),
    );
  }

  void clearNavigation() {
    emit(state.copyWith(clearLastStartedOrderId: true));
  }

  Future<void> updateNote(String sampleId, String note) async {
    final result = await _repository.updateSampleNote(sampleId, note);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SampleManagementStatus.error,
        errorMessage: failure.message,
      )),
      (_) => null,
    );
  }
}
