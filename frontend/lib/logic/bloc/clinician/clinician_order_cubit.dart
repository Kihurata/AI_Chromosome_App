import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/sample.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/usecases/sample/collect_physical_sample.dart';
import '../../../domain/usecases/sample/transfer_sample_to_lab.dart';
import '../../../domain/usecases/test_order/create_genetic_test_order.dart';
import 'clinician_order_state.dart';

class ClinicianOrderCubit extends Cubit<ClinicianOrderState> {
  final CreateGeneticTestOrder createGeneticTestOrder;
  final CollectPhysicalSample collectPhysicalSample;
  final TransferSampleToLab transferSampleToLab;

  ClinicianOrderCubit({
    required this.createGeneticTestOrder,
    required this.collectPhysicalSample,
    required this.transferSampleToLab,
  }) : super(ClinicianOrderInitial());

  Future<void> submitTestOrder(TestOrder testOrder) async {
    emit(ClinicianOrderLoading());
    final result = await createGeneticTestOrder(testOrder);
    result.fold(
      (failure) => emit(ClinicianOrderError(failure.message)),
      (_) => emit(const ClinicianOrderSuccess('Tạo phiếu xét nghiệm thành công')),
    );
  }

  Future<void> collectSample(Sample sample) async {
    emit(ClinicianOrderLoading());
    final result = await collectPhysicalSample(sample);
    result.fold(
      (failure) => emit(ClinicianOrderError(failure.message)),
      (_) => emit(const ClinicianOrderSuccess('Thu thập mẫu thành công')),
    );
  }

  Future<void> transferToLab(String sampleId) async {
    emit(ClinicianOrderLoading());
    final result = await transferSampleToLab(sampleId);
    result.fold(
      (failure) => emit(ClinicianOrderError(failure.message)),
      (_) => emit(const ClinicianOrderSuccess('Chuyển mẫu đến phòng thí nghiệm thành công')),
    );
  }
}
