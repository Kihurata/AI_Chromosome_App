import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/sample.dart';
import '../../../domain/entities/test_order.dart';
import '../../../domain/usecases/sample/collect_physical_sample.dart';
import '../../../domain/usecases/sample/transfer_sample_to_lab.dart';
import '../../../domain/usecases/test_order/create_genetic_test_order.dart';
import '../../../domain/usecases/test_order/watch_all_orders.dart';
import 'clinician_order_state.dart';

class ClinicianOrderCubit extends Cubit<ClinicianOrderState> {
  final CreateGeneticTestOrder createGeneticTestOrder;
  final CollectPhysicalSample collectPhysicalSample;
  final TransferSampleToLab transferSampleToLab;
  final WatchAllOrders watchAllOrders;

  ClinicianOrderCubit({
    required this.createGeneticTestOrder,
    required this.collectPhysicalSample,
    required this.transferSampleToLab,
    required this.watchAllOrders,
  }) : super(ClinicianOrderInitial());

  Future<void> submitTestOrder(TestOrder testOrder) async {
    emit(ClinicianOrderLoading());
    final result = await createGeneticTestOrder(testOrder);
    result.fold(
      (failure) => emit(ClinicianOrderError(failure.message)),
      (_) => emit(const ClinicianOrderSuccess('Tạo phiếu xét nghiệm thành công')),
    );
  }

  Future<void> submitOrderWithSample({
    required TestOrder order,
    required Sample sample,
  }) async {
    emit(ClinicianOrderLoading());
    
    // 1. Create Test Order
    final orderResult = await createGeneticTestOrder(order);
    
    final success = await orderResult.fold(
      (failure) async {
        emit(ClinicianOrderError('Lỗi tạo phiếu: ${failure.message}'));
        return false;
      },
      (_) async {
        // 2. Create Physical Sample
        final sampleResult = await collectPhysicalSample(sample);
        return sampleResult.fold(
          (failure) {
            emit(ClinicianOrderError('Lỗi ghi nhận mẫu: ${failure.message}'));
            return false;
          },
          (_) => true,
        );
      },
    );

    if (success) {
      emit(const ClinicianOrderSuccess('Đã tạo phiếu xét nghiệm và ghi nhận mẫu bệnh phẩm'));
    }
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

  Future<void> listenToAllOrders() async {
    await for (final result in watchAllOrders()) {
      if (isClosed) break;
      result.fold(
        (failure) => emit(ClinicianOrderError(failure.message)),
        (orders) => emit(TestOrdersLoaded(orders)),
      );
    }
  }
}
