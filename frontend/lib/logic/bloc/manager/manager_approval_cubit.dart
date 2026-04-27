import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/test_order/approve_karyotype_result.dart';
import '../../../domain/usecases/test_order/reject_karyotype_result.dart';
import 'manager_approval_state.dart';

class ManagerApprovalCubit extends Cubit<ManagerApprovalState> {
  final ApproveKaryotypeResult approveKaryotypeResult;
  final RejectKaryotypeResult rejectKaryotypeResult;

  ManagerApprovalCubit({
    required this.approveKaryotypeResult,
    required this.rejectKaryotypeResult,
  }) : super(ManagerApprovalInitial());

  Future<void> approve(String orderId) async {
    emit(ManagerApprovalLoading());
    final result = await approveKaryotypeResult(orderId);
    result.fold(
      (failure) => emit(ManagerApprovalError(failure.message)),
      (_) => emit(const ManagerApprovalSuccess('Kết quả karyotype đã được phê duyệt')),
    );
  }

  Future<void> reject(String orderId) async {
    emit(ManagerApprovalLoading());
    final result = await rejectKaryotypeResult(orderId);
    result.fold(
      (failure) => emit(ManagerApprovalError(failure.message)),
      (_) => emit(const ManagerApprovalSuccess('Kết quả karyotype đã bị từ chối')),
    );
  }
}
