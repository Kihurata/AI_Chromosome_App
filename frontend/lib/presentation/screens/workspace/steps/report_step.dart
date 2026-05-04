import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../../widgets/shared/form/app_buttons.dart';


class ReportStep extends StatelessWidget {
  const ReportStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BlocConsumer<WorkspaceCubit, WorkspaceState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == WorkspaceStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi báo cáo thành công!'), backgroundColor: Colors.green),
                );
                // Return to dashboard
                context.goNamed('specialist-dashboard');
              } else if (state.status == WorkspaceStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${state.errorMessage}'), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined, size: 64, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Bước 5: Lập Báo cáo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tất cả các thông tin NST đồ, chẩn đoán ISCN và ghi chú sẽ được đính kèm vào báo cáo. Vui lòng kiểm tra kỹ trước khi hoàn tất.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  
                  // Summary Box
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Số lượng NST', '${state.chromosomes.length} NST'),
                        const Divider(height: 24),
                        _buildSummaryRow('Đã phân loại', '${state.chromosomes.where((c) => c.label != '' && c.label != 'unassigned').length} NST'),
                        const Divider(height: 24),
                        _buildSummaryRow('Karyotype', 'Đã nhập ISCN'), // In real app, bind to Step 4's controller value
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  AppPrimaryButton(
                    text: 'Hoàn tất & Gửi Phê duyệt',
                    isLoading: state.status == WorkspaceStatus.loading,
                    onPressed: state.status == WorkspaceStatus.loading
                        ? null
                        : () => context.read<WorkspaceCubit>().submitAnalysis(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
