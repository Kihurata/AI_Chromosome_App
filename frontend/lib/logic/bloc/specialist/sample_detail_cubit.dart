import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/usecases/get_sample_by_id_usecase.dart';
import '../../../../domain/usecases/update_sample_note_usecase.dart';
import '../../../../domain/usecases/test_order/get_test_order_by_id.dart';
import '../../../../domain/usecases/sample/collect_physical_sample.dart';
import '../../../../domain/entities/sample.dart';
import 'sample_detail_state.dart';

@injectable
class SampleDetailCubit extends Cubit<SampleDetailState> {
  final GetSampleByIdUsecase getSampleById;
  final UpdateSampleNoteUsecase updateSampleNote;
  final GetTestOrderById getTestOrderById;
  final CollectPhysicalSample collectPhysicalSample;

  SampleDetailCubit({
    required this.getSampleById,
    required this.updateSampleNote,
    required this.getTestOrderById,
    required this.collectPhysicalSample,
  }) : super(SampleDetailInitial());

  Future<void> loadSample(String id) async {
    emit(SampleDetailLoading());
    final result = await getSampleById(id);
    if (isClosed) return;
    
    result.fold(
      (failure) => emit(SampleDetailError(failure.message)),
      (sample) => emit(SampleDetailSuccess(sample)),
    );
  }

  Future<void> loadTestOrder(String id) async {
    emit(SampleDetailLoading());
    final result = await getTestOrderById(id);
    if (isClosed) return;
    
    result.fold(
      (failure) => emit(SampleDetailError(failure.message)),
      (order) {
        // Create a dummy sample from order details to populate UI
        final dummySample = Sample(
          id: '',
          testOrderId: order.id,
          patientName: order.patientName,
          patientCode: order.patientCode,
          sampleType: 'Máu',
          collectedBy: '',
          collectedAt: DateTime.now(),
          status: SampleStatus.collected,
        );
        emit(SampleDetailSuccess(dummySample));
      },
    );
  }

  Future<void> createSample(Sample sample) async {
    emit(SampleDetailLoading());
    final result = await collectPhysicalSample(sample);
    if (isClosed) return;
    
    result.fold(
      (failure) => emit(SampleDetailError(failure.message)),
      (_) => emit(SampleDetailSuccess(sample)), // Emit success with the created sample
    );
  }

  Future<void> saveNote(String id, String note) async {
    final currentState = state;
    if (currentState is SampleDetailSuccess) {
      emit(SampleDetailLoading());
      final result = await updateSampleNote(id, note);
      if (isClosed) return;
      
      result.fold(
        (failure) {
          emit(SampleDetailError(failure.message));
          if (!isClosed) emit(currentState); // Revert
        },
        (_) async {
          await loadSample(id);
        },
      );
    }
  }
}
