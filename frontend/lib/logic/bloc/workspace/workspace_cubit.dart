import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chromosome.dart';
import '../../../domain/usecases/specialist/update_chromosome_position.dart';
import '../../../domain/usecases/test_order/submit_analysis_result.dart';
import '../../../domain/repositories/workspace_repository.dart';

enum WorkspaceStatus { initial, loading, success, error }

class WorkspaceState {
  final List<Chromosome> chromosomes;
  final String? selectedId;
  final List<String> selectedImageIds;
  final int currentStep;
  final int maxReachedStep;
  final WorkspaceStatus status;
  final String? errorMessage;
  final bool isDirty;

  WorkspaceState({
    required this.chromosomes,
    this.selectedId,
    this.selectedImageIds = const [],
    this.currentStep = 1,
    this.maxReachedStep = 1,
    this.status = WorkspaceStatus.initial,
    this.errorMessage,
    this.isDirty = false,
  });

  WorkspaceState copyWith({
    List<Chromosome>? chromosomes,
    String? selectedId,
    List<String>? selectedImageIds,
    int? currentStep,
    int? maxReachedStep,
    WorkspaceStatus? status,
    String? errorMessage,
    bool? isDirty,
  }) {
    return WorkspaceState(
      chromosomes: chromosomes ?? this.chromosomes,
      selectedId: selectedId ?? this.selectedId,
      selectedImageIds: selectedImageIds ?? this.selectedImageIds,
      currentStep: currentStep ?? this.currentStep,
      maxReachedStep: maxReachedStep ?? this.maxReachedStep,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final UpdateChromosomePosition updatePositionUsecase;
  final SubmitAnalysisResult submitAnalysisUsecase;
  final WorkspaceRepository workspaceRepository;
  final String orderId;

  WorkspaceCubit({
    required this.updatePositionUsecase,
    required this.submitAnalysisUsecase,
    required this.workspaceRepository,
    required this.orderId,
  }) : super(WorkspaceState(chromosomes: []));

  // Sync with Riverpod raw stream
  void syncFromStream(List<Chromosome> streamData) {
    // Priority: If we are not currently dragging something, 
    // or we want to overwrite local state with DB source.
    emit(state.copyWith(chromosomes: streamData));
  }

  Future<void> fetchChromosomesForStep3() async {
    if (state.selectedImageIds.isEmpty) return;
    
    emit(state.copyWith(status: WorkspaceStatus.loading));
    final selectedImageId = state.selectedImageIds.first;
    final result = await workspaceRepository.fetchChromosomesFromStorage(
      orderId,
      selectedImageId,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: WorkspaceStatus.error,
        errorMessage: failure.message,
      )),
      (chromosomes) => emit(state.copyWith(
        status: WorkspaceStatus.success,
        chromosomes: chromosomes,
        isDirty: false,
      )),
    );
  }

  Future<void> saveKaryogram() async {
    if (state.selectedImageIds.isEmpty) return;
    
    emit(state.copyWith(status: WorkspaceStatus.loading));
    final selectedImageId = state.selectedImageIds.first;
    
    final result = await workspaceRepository.saveKaryogram(
      orderId,
      selectedImageId,
      state.chromosomes,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: WorkspaceStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: WorkspaceStatus.success,
        isDirty: false,
      )),
    );
  }

  // Handle local dragging/rotation (Temporary state + background sync)
  void updatePosition(String id, double newX, double newY) {
    Chromosome? updatedChromosome;
    final updatedList = state.chromosomes.map((item) {
      if (item.id == id) {
        updatedChromosome = item.copyWith(x: newX, y: newY);
        return updatedChromosome!;
      }
      return item;
    }).toList();

    // 1. Immediate UI update for smooth dragging
    emit(state.copyWith(chromosomes: updatedList, selectedId: id, isDirty: true));

    // 2. Background sync to Firestore
    if (updatedChromosome != null) {
      updatePositionUsecase(orderId, updatedChromosome!);
    }
  }

  void assignChromosomeLabel(String id, String newLabel) {
    Chromosome? updatedChromosome;
    final updatedList = state.chromosomes.map((item) {
      if (item.id == id) {
        updatedChromosome = item.copyWith(label: newLabel);
        return updatedChromosome!;
      }
      return item;
    }).toList();

    emit(state.copyWith(chromosomes: updatedList, selectedId: id, isDirty: true));

    if (updatedChromosome != null) {
      updatePositionUsecase(orderId, updatedChromosome!);
    }
  }

  void selectItem(String? id) {
    emit(state.copyWith(selectedId: id));
  }

  void toggleImageSelection(String imageId) {
    if (state.selectedImageIds.contains(imageId)) {
      emit(state.copyWith(selectedImageIds: []));
    } else {
      emit(state.copyWith(selectedImageIds: [imageId]));
    }
  }

  void goToStep(int step) {
    if (step >= 1 && step <= state.maxReachedStep) {
      emit(state.copyWith(currentStep: step));
    }
  }

  void nextStep() {
    if (state.currentStep < 5) {
      final next = state.currentStep + 1;
      final newMax = next > state.maxReachedStep ? next : state.maxReachedStep;
      emit(state.copyWith(currentStep: next, maxReachedStep: newMax));
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> submitAnalysis() async {
    emit(state.copyWith(status: WorkspaceStatus.loading));
    final result = await submitAnalysisUsecase(orderId);
    result.fold(
      (failure) => emit(state.copyWith(status: WorkspaceStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: WorkspaceStatus.success)),
    );
  }
}

