import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/usecases/test_order/get_order_by_id.dart';
import '../../../../domain/usecases/test_order/approve_karyotype_result.dart';
import '../../../../domain/usecases/test_order/reject_karyotype_result.dart';
import '../../../../domain/usecases/test_order/update_report_content.dart';
import '../../../../domain/repositories/workspace_repository.dart';
import '../../workspace/workspace_cubit.dart';
import 'manager_approval_state.dart';

@injectable
class ManagerApprovalCubit extends Cubit<ManagerApprovalState> {
  final GetOrderById getOrderByIdUsecase;
  final ApproveKaryotypeResult approveKaryotypeResultUsecase;
  final RejectKaryotypeResult rejectKaryotypeResultUsecase;
  final UpdateReportContent updateReportContentUsecase;
  final WorkspaceRepository workspaceRepository;

  ManagerApprovalCubit({
    required this.getOrderByIdUsecase,
    required this.approveKaryotypeResultUsecase,
    required this.rejectKaryotypeResultUsecase,
    required this.updateReportContentUsecase,
    required this.workspaceRepository,
  }) : super(const ManagerApprovalState());

  Future<void> loadOrderData(String orderId) async {
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
          debugPrint('Error finding metaphase images: $e');
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

  Future<void> approveOrder(String orderId, String finalReportContent) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));

    final saveResult = await updateReportContentUsecase(orderId, finalReportContent);

    await saveResult.fold(
      (failure) async {
        emit(state.copyWith(status: WorkspaceStatus.error, errorMessage: failure.message));
      },
      (_) async {
        final result = await approveKaryotypeResultUsecase(orderId);
        result.fold(
          (failure) => emit(state.copyWith(status: WorkspaceStatus.error, errorMessage: failure.message)),
          (_) => emit(state.copyWith(status: WorkspaceStatus.success)),
        );
      },
    );
  }

  Future<void> rejectOrder(String orderId, String reason) async {
    emit(state.copyWith(status: WorkspaceStatus.loading));

    final result = await rejectKaryotypeResultUsecase(orderId, reason);
    result.fold(
      (failure) => emit(state.copyWith(status: WorkspaceStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: WorkspaceStatus.success)),
    );
  }
}
