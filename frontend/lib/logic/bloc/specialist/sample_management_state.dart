import 'package:equatable/equatable.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../core/models/filter_options.dart';

enum SampleManagementStatus { initial, loading, loaded, error }

class SampleManagementState extends Equatable {
  final SampleManagementStatus status;
  final List<Sample> allSamples;
  final List<Sample> filteredSamples;
  final String searchKeyword;
  final SampleStatus? filterStatus;
  final AppSortOrder sortOrder;
  final AppDateRangePreset dateRangePreset;
  final String? errorMessage;
  final String? lastStartedOrderId;
  final String? notificationMessage;

  const SampleManagementState({
    this.status = SampleManagementStatus.initial,
    this.allSamples = const [],
    this.filteredSamples = const [],
    this.searchKeyword = '',
    this.filterStatus,
    this.sortOrder = AppSortOrder.newest,
    this.dateRangePreset = AppDateRangePreset.all,
    this.errorMessage,
    this.lastStartedOrderId,
    this.notificationMessage,
  });

  SampleManagementState copyWith({
    SampleManagementStatus? status,
    List<Sample>? allSamples,
    List<Sample>? filteredSamples,
    String? searchKeyword,
    SampleStatus? filterStatus,
    bool clearStatusFilter = false,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
    String? errorMessage,
    String? lastStartedOrderId,
    bool clearLastStartedOrderId = false,
    String? notificationMessage,
    bool clearNotificationMessage = false,
  }) {
    return SampleManagementState(
      status: status ?? this.status,
      allSamples: allSamples ?? this.allSamples,
      filteredSamples: filteredSamples ?? this.filteredSamples,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      filterStatus: clearStatusFilter ? null : (filterStatus ?? this.filterStatus),
      sortOrder: sortOrder ?? this.sortOrder,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
      errorMessage: errorMessage ?? this.errorMessage,
      lastStartedOrderId: clearLastStartedOrderId ? null : (lastStartedOrderId ?? this.lastStartedOrderId),
      notificationMessage: clearNotificationMessage ? null : (notificationMessage ?? this.notificationMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        allSamples,
        filteredSamples,
        searchKeyword,
        filterStatus,
        sortOrder,
        dateRangePreset,
        errorMessage,
        lastStartedOrderId,
        notificationMessage,
      ];
}
