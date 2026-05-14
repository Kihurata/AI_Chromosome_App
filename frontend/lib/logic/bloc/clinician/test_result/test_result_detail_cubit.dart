import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/usecases/test_order/get_order_by_id.dart';
import '../../../../domain/repositories/workspace_repository.dart';
import '../../workspace/workspace_cubit.dart';
import 'test_result_detail_state.dart';

@injectable
class TestResultDetailCubit extends Cubit<TestResultDetailState> {
  final GetOrderById getOrderByIdUsecase;
  final WorkspaceRepository workspaceRepository;

  TestResultDetailCubit({
    required this.getOrderByIdUsecase,
    required this.workspaceRepository,
  }) : super(const TestResultDetailState());

  Future<void> loadData(String orderId) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));

    final orderResult = await getOrderByIdUsecase(orderId);

    await orderResult.fold(
      (failure) async {
        emit(state.copyWith(status: WorkspaceStatus.error, errorMessage: failure.message));
      },
      (order) async {
        // Find a valid metaphase image ID to load chromosomes
        String targetImageId = 'image_1';
        try {
          final imagesStream = workspaceRepository.watchMetaphaseImages(orderId);
          final firstResult = await imagesStream.first;
          firstResult.fold((_) => null, (images) {
            if (images.isNotEmpty) {
              targetImageId = images.first.id;
            }
          });
        } catch (e) {
          debugPrint('Error finding metaphase images for viewing: $e');
        }

        final chromosomesResult = await workspaceRepository.fetchChromosomesFromStorage(orderId, targetImageId);

        chromosomesResult.fold(
          (failure) => emit(state.copyWith(
            testOrder: order,
            status: WorkspaceStatus.success,
            chromosomes: [],
          )),
          (chromosomes) => emit(state.copyWith(
            testOrder: order,
            status: WorkspaceStatus.success,
            chromosomes: chromosomes,
          )),
        );
      },
    );
  }
}
