import 'package:equatable/equatable.dart';
import '../../../../domain/entities/sample.dart';

enum SampleManagementStatus { initial, loading, loaded, error }

class SampleManagementState extends Equatable {
  final SampleManagementStatus status;
  final List<Sample> allSamples;
  final List<Sample> filteredSamples;
  final SampleStatus? filterStatus;
  final String? errorMessage;

  const SampleManagementState({
    this.status = SampleManagementStatus.initial,
    this.allSamples = const [],
    this.filteredSamples = const [],
    this.filterStatus,
    this.errorMessage,
  });

  SampleManagementState copyWith({
    SampleManagementStatus? status,
    List<Sample>? allSamples,
    List<Sample>? filteredSamples,
    SampleStatus? filterStatus,
    String? errorMessage,
  }) {
    return SampleManagementState(
      status: status ?? this.status,
      allSamples: allSamples ?? this.allSamples,
      filteredSamples: filteredSamples ?? this.filteredSamples,
      filterStatus: filterStatus, // Allowing null to clear filter
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allSamples,
        filteredSamples,
        filterStatus,
        errorMessage,
      ];
}
