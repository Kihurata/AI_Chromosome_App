import 'package:equatable/equatable.dart';
import '../../../domain/entities/examination.dart';
import '../../../../core/models/filter_options.dart';

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
  final List<Examination> allExaminations;
  final List<Examination> filteredExaminations;
  final String searchQuery;
  final AppSortOrder sortOrder;
  final AppDateRangePreset dateRangePreset;

  const ExaminationLoaded({
    required this.allExaminations,
    required this.filteredExaminations,
    this.searchQuery = '',
    this.sortOrder = AppSortOrder.newest,
    this.dateRangePreset = AppDateRangePreset.all,
  });

  ExaminationLoaded copyWith({
    List<Examination>? allExaminations,
    List<Examination>? filteredExaminations,
    String? searchQuery,
    AppSortOrder? sortOrder,
    AppDateRangePreset? dateRangePreset,
  }) {
    return ExaminationLoaded(
      allExaminations: allExaminations ?? this.allExaminations,
      filteredExaminations: filteredExaminations ?? this.filteredExaminations,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
    );
  }

  @override
  List<Object?> get props => [
        allExaminations,
        filteredExaminations,
        searchQuery,
        sortOrder,
        dateRangePreset,
      ];
}
