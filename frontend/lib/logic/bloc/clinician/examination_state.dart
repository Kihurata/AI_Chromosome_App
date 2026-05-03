import 'package:equatable/equatable.dart';
import '../../../domain/entities/examination.dart';

abstract class ExaminationState extends Equatable {
  const ExaminationState();

  @override
  List<Object?> get props => [];
}

class ExaminationInitial extends ExaminationState {}

class ExaminationLoading extends ExaminationState {}

class ExaminationSaveSuccess extends ExaminationState {
  final String message;
  const ExaminationSaveSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExaminationError extends ExaminationState {
  final String message;
  const ExaminationError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExaminationLoaded extends ExaminationState {
  final List<Examination> examinations;
  const ExaminationLoaded(this.examinations);

  @override
  List<Object?> get props => [examinations];
}
