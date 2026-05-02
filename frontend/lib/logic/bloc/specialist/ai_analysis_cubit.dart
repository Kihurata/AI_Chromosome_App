import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/metaphase_image.dart';
import '../../../domain/repositories/workspace_repository.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/specialist/upload_image_for_ai_analysis.dart';
import '../../../domain/usecases/specialist/trigger_ai_analysis.dart';
import 'ai_analysis_state.dart';

@injectable
class AiAnalysisCubit extends Cubit<AiAnalysisState> {
  final UploadImageForAiAnalysis uploadUsecase;
  final TriggerAiAnalysis triggerAiUsecase;
  final WorkspaceRepository workspaceRepository;
  String? _analyzingImageId;

  AiAnalysisCubit({
    required this.uploadUsecase,
    required this.triggerAiUsecase,
    required this.workspaceRepository,
  }) : super(AiAnalysisInitial());

  String? get analyzingImageId => _analyzingImageId;

  Future<void> startAnalysis(File imageFile, String orderId) async {
    emit(AiAnalysisUploading());

    final uploadResult = await uploadUsecase(imageFile, orderId);

    uploadResult.fold(
      (failure) => emit(AiAnalysisError(failure.message)),
      (_) {
        emit(AiAnalysisWaitingForBackend());
        _listenToBackendProgress(orderId);
      },
    );
  }

  Future<void> triggerAnalysis(String orderId, [String? imageId]) async {
    _analyzingImageId = imageId;
    emit(AiAnalysisWaitingForBackend());

    final result = await triggerAiUsecase(orderId);

    result.fold(
      (failure) {
        _analyzingImageId = null;
        emit(AiAnalysisError(failure.message));
      },
      (_) {
        // Start listening to Firestore progress
        _listenToBackendProgress(orderId);
      },
    );
  }

  Future<void> _listenToBackendProgress(String orderId) async {
    // Following Critical Pattern: await for instead of emit.forEach
    await for (final result in workspaceRepository.watchMetaphaseImageRecord(orderId)) {
      if (isClosed) break;
      
      bool shouldBreak = false;
      result.fold(
        (failure) {
          emit(AiAnalysisError(failure.message));
          shouldBreak = true;
        },
        (image) {
          if (image.status == AiProcessingStatus.completed) {
            _analyzingImageId = null;
            emit(AiAnalysisCompleted(processingTimeMs: image.processingTimeMs));
            shouldBreak = true;
          } else if (image.status == AiProcessingStatus.failed) {
            _analyzingImageId = null;
            emit(const AiAnalysisError('AI processing failed on backend.'));
            shouldBreak = true;
          }
        },
      );

      if (shouldBreak) break;
    }
  }
}
