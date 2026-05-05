import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/usecases/get_sample_by_id_usecase.dart';
import '../../../../domain/usecases/update_sample_note_usecase.dart';
import 'sample_detail_state.dart';

@injectable
class SampleDetailCubit extends Cubit<SampleDetailState> {
  final GetSampleByIdUsecase getSampleById;
  final UpdateSampleNoteUsecase updateSampleNote;

  SampleDetailCubit({
    required this.getSampleById,
    required this.updateSampleNote,
  }) : super(SampleDetailInitial());

  Future<void> loadSample(String id) async {
    emit(SampleDetailLoading());
    final result = await getSampleById(id);
    result.fold(
      (failure) => emit(SampleDetailError(failure.message)),
      (sample) => emit(SampleDetailSuccess(sample)),
    );
  }

  Future<void> saveNote(String id, String note) async {
    final currentState = state;
    if (currentState is SampleDetailSuccess) {
      emit(SampleDetailLoading());
      final result = await updateSampleNote(id, note);
      
      result.fold(
        (failure) {
          emit(SampleDetailError(failure.message));
          emit(currentState); // Revert
        },
        (_) async {
          await loadSample(id);
        },
      );
    }
  }
}
