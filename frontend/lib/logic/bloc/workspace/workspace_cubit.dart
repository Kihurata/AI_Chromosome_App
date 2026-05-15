import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chromosome.dart';
import '../../../domain/usecases/specialist/update_chromosome_position.dart';
import '../../../domain/usecases/test_order/submit_analysis_result.dart';
import '../../../domain/usecases/test_order/update_report_content.dart';
import '../../../domain/repositories/workspace_repository.dart';
import '../../../domain/entities/metaphase_image.dart';

enum WorkspaceStatus { initial, loading, success, error, loaded }

class WorkspaceState {
  final List<Chromosome> chromosomes;
  final String? selectedId;
  final List<String> selectedImageIds;
  final int currentStep;
  final int maxReachedStep;
  final WorkspaceStatus status;
  final String? errorMessage;
  final bool isDirty;
  final List<DiagnosisSuggestion> suggestions;

  WorkspaceState({
    required this.chromosomes,
    this.selectedId,
    this.selectedImageIds = const [],
    this.currentStep = 1,
    this.maxReachedStep = 1,
    this.status = WorkspaceStatus.initial,
    this.errorMessage,
    this.isDirty = false,
    this.suggestions = const [],
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
    List<DiagnosisSuggestion>? suggestions,
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
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final UpdateChromosomePosition updatePositionUsecase;
  final SubmitAnalysisResult submitAnalysisUsecase;
  final UpdateReportContent updateReportContentUsecase;
  final WorkspaceRepository workspaceRepository;
  final String orderId;

  WorkspaceCubit({
    required this.updatePositionUsecase,
    required this.submitAnalysisUsecase,
    required this.updateReportContentUsecase,
    required this.workspaceRepository,
    required this.orderId,
  }) : super(WorkspaceState(chromosomes: []));

  // Sync with Riverpod raw stream
  void syncFromStream(List<Chromosome> streamData) {
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
      (failure) => emit(
        state.copyWith(
          status: WorkspaceStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (chromosomes) async {
        final imageResult = await workspaceRepository.getMetaphaseImage(
          orderId,
          selectedImageId,
        );

        List<DiagnosisSuggestion> suggestions = [];
        imageResult.fold(
          (_) => null,
          (image) => suggestions = image.aiSuggestions,
        );

        emit(
          state.copyWith(
            status: WorkspaceStatus.loaded,
            chromosomes: chromosomes,
            suggestions: suggestions,
            isDirty: false,
          ),
        );
      },
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
      (failure) => emit(
        state.copyWith(
          status: WorkspaceStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (suggestions) => emit(
        state.copyWith(
          status: WorkspaceStatus.success,
          suggestions: suggestions,
          isDirty: false,
        ),
      ),
    );
  }

  void updatePosition(String id, double newX, double newY) {
    Chromosome? updatedChromosome;
    final updatedList = state.chromosomes.map((item) {
      if (item.id == id) {
        updatedChromosome = item.copyWith(x: newX, y: newY);
        return updatedChromosome!;
      }
      return item;
    }).toList();

    emit(
      state.copyWith(chromosomes: updatedList, selectedId: id, isDirty: true),
    );

    if (updatedChromosome != null && state.selectedImageIds.isNotEmpty) {
      final selectedImageId = state.selectedImageIds.first;
      updatePositionUsecase(orderId, selectedImageId, updatedChromosome!);
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

    emit(
      state.copyWith(chromosomes: updatedList, selectedId: id, isDirty: true),
    );

    if (updatedChromosome != null && state.selectedImageIds.isNotEmpty) {
      final selectedImageId = state.selectedImageIds.first;
      updatePositionUsecase(orderId, selectedImageId, updatedChromosome!);
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

  Future<void> submitAnalysis(String reportContent) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));

    // 1. Save report content
    final saveResult = await updateReportContentUsecase(orderId, reportContent);

    await saveResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: WorkspaceStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        // 2. Submit analysis
        final result = await submitAnalysisUsecase(orderId);
        result.fold(
          (failure) => emit(
            state.copyWith(
              status: WorkspaceStatus.error,
              errorMessage: failure.message,
            ),
          ),
          (_) => emit(state.copyWith(status: WorkspaceStatus.success)),
        );
      },
    );
  }
}
