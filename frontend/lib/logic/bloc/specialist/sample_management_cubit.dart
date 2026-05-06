import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../domain/repositories/sample_repository.dart';
import 'sample_management_state.dart';

@injectable
class SampleManagementCubit extends Cubit<SampleManagementState> {
  final SampleRepository _repository;
  StreamSubscription? _samplesSubscription;

  SampleManagementCubit(this._repository) : super(const SampleManagementState());

  void loadSamples() {
    emit(state.copyWith(status: SampleManagementStatus.loading));
    _samplesSubscription?.cancel();
    _samplesSubscription = _repository.watchSamples().listen(
      (result) {
        result.fold(
          (failure) => emit(state.copyWith(
            status: SampleManagementStatus.error,
            errorMessage: failure.message,
          )),
          (samples) {
            final filtered = _applyFilter(samples, state.filterStatus);
            emit(state.copyWith(
              status: SampleManagementStatus.loaded,
              allSamples: samples,
              filteredSamples: filtered,
            ));
          },
        );
      },
    );
  }

  void setFilter(SampleStatus? status) {
    final filtered = _applyFilter(state.allSamples, status);
    emit(state.copyWith(
      filterStatus: status,
      filteredSamples: filtered,
    ));
  }

  List<Sample> _applyFilter(List<Sample> samples, SampleStatus? status) {
    if (status == null) return samples;
    return samples.where((s) => s.status == status).toList();
  }

  Future<void> updateStatus(String sampleId, SampleStatus status) async {
    final result = await _repository.updateSampleStatus(sampleId, status);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SampleManagementStatus.error,
        errorMessage: failure.message,
      )),
      (_) => null, // Real-time stream will update the UI
    );
  }

  @override
  Future<void> close() {
    _samplesSubscription?.cancel();
    return super.close();
  }
}
