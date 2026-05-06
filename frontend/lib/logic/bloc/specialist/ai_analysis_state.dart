import 'package:equatable/equatable.dart';

abstract class AiAnalysisState extends Equatable {
  const AiAnalysisState();
  
  @override
  List<Object?> get props => [];
}

class AiAnalysisInitial extends AiAnalysisState {}

class AiAnalysisUploading extends AiAnalysisState {}
class AiAnalysisUploadingProgress extends AiAnalysisState {
  final int current;
  final int total;
  const AiAnalysisUploadingProgress(this.current, this.total);
  
  @override
  List<Object?> get props => [current, total];
}

class AiAnalysisWaitingForBackend extends AiAnalysisState {}
class AiAnalysisUploadCompleted extends AiAnalysisState {}

class AiAnalysisCompleted extends AiAnalysisState {
  final int? processingTimeMs;
  const AiAnalysisCompleted({this.processingTimeMs});
  
  @override
  List<Object?> get props => [processingTimeMs];
}

class AiAnalysisError extends AiAnalysisState {
  final String message;
  const AiAnalysisError(this.message);
  
  @override
  List<Object?> get props => [message];
}
