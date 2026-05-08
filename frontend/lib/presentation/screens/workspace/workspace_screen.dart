import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/workspace/workspace_cubit.dart';
import 'steps/screening_step.dart';
import 'steps/slicing_step.dart';
import 'steps/karyogram_step.dart';
import 'steps/qc_diagnostic_step.dart';
import 'steps/report_step.dart';
import '../../widgets/shared/form/app_buttons.dart';

import '../../../logic/bloc/specialist/ai_analysis_cubit.dart';
import '../../../logic/bloc/specialist/ai_analysis_state.dart';

class WorkspaceScreen extends StatelessWidget {
  final String orderId;

  const WorkspaceScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiAnalysisCubit, AiAnalysisState>(
      listener: (context, state) {
        if (!context.mounted) return;
        if (state is AiAnalysisCompleted) {
          // Do not navigate automatically as per new Spec
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phân tích AI hoàn tất! Bạn có thể xem kết quả.'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AiAnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isAnalyzing =
            state is AiAnalysisWaitingForBackend ||
            state is AiAnalysisUploadingProgress;

        return Stack(
          children: [
            BlocListener<WorkspaceCubit, WorkspaceState>(
              listenWhen: (previous, current) => 
                (previous.currentStep != current.currentStep && current.currentStep == 3) ||
                (previous.status != current.status),
              listener: (context, workspaceState) {
                if (!context.mounted) return;
                if (workspaceState.currentStep == 3 && workspaceState.chromosomes.isEmpty && workspaceState.status != WorkspaceStatus.loading) {
                  context.read<WorkspaceCubit>().fetchChromosomesForStep3();
                }
                
                if (workspaceState.status == WorkspaceStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thành công'), backgroundColor: Colors.green),
                  );
                } else if (workspaceState.status == WorkspaceStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${workspaceState.errorMessage}'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Scaffold(
                backgroundColor: const Color(0xFFF8F9FA),
                body: Column(
                  children: [
                  // Stepper Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                      builder: (context, state) {
                        return Row(
                          children: [
                            _buildStepIndicator(
                              1,
                              'Sàng lọc',
                              state,
                              context,
                            ),
                            _buildLine(1, state.maxReachedStep),
                            _buildStepIndicator(
                              2,
                              'Tách NST',
                              state,
                              context,
                            ),
                            _buildLine(2, state.maxReachedStep),
                            _buildStepIndicator(
                              3,
                              'Lập NST đồ',
                              state,
                              context,
                            ),
                            _buildLine(3, state.maxReachedStep),
                            _buildStepIndicator(
                              4,
                              'Phê duyệt QC',
                              state,
                              context,
                            ),
                            _buildLine(4, state.maxReachedStep),
                            _buildStepIndicator(
                              5,
                              'Báo cáo',
                              state,
                              context,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Main Content Area
                  Expanded(
                    child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                      builder: (context, state) {
                        switch (state.currentStep) {
                          case 1:
                            return ScreeningStep(orderId: orderId);
                          case 2:
                            return const SlicingStep();
                          case 3:
                            return const KaryogramStep();
                          case 4:
                            return const QcDiagnosticStep();
                          case 5:
                            return const ReportStep();
                          default:
                            return const Center(child: Text('Unknown Step'));
                        }
                      },
                    ),
                  ),

                  // Navigation Controls
                  BlocBuilder<WorkspaceCubit, WorkspaceState>(
                    builder: (context, state) {
                      final isStep1 = state.currentStep == 1;
                      final hasSelection = state.selectedImageIds.isNotEmpty;
                      final canProceed = !isStep1 || hasSelection;

                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppSecondaryButton(
                              text: 'Quay lại',
                              onPressed: state.currentStep > 1
                                  ? () => _handleNavigation(context, state, () => context.read<WorkspaceCubit>().previousStep())
                                  : null,
                            ),
                            Row(
                              children: [
                                if (state.currentStep == 3 && state.isDirty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      onPressed: () => context.read<WorkspaceCubit>().saveKaryogram(),
                                      child: const Text('Lưu lại', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                AppPrimaryButton(
                                  text: 'Tiếp tục',
                                  onPressed: canProceed
                                      ? () => _handleNavigation(context, state, () => context.read<WorkspaceCubit>().nextStep())
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ), // Close BlocListener

            // Full-screen Loading Overlay
            if (isAnalyzing)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 24),
                      Text(
                        state is AiAnalysisUploadingProgress
                            ? 'Đang tải ảnh lên (${state.current}/${state.total})...'
                            : 'Đang phân tích cấu trúc nhiễm sắc thể...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, WorkspaceState state, VoidCallback navigate) {
    if (state.currentStep == 3 && state.isDirty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Cảnh báo thay đổi chưa lưu'),
          content: const Text('Bạn có thay đổi ở bước này. Bạn có chắc chắn muốn rời khỏi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                navigate();
              },
              child: const Text('Tiếp tục', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      navigate();
    }
  }

  Widget _buildStepIndicator(
    int step,
    String title,
    WorkspaceState state,
    BuildContext context,
  ) {
    final int currentStep = state.currentStep;
    final int maxReached = state.maxReachedStep;
    final bool isActive = step == currentStep;
    final bool isCompleted = step < currentStep || step <= maxReached;
    final bool isClickable = step <= maxReached;

    final Color color = isActive
        ? Theme.of(context).primaryColor
        : (isCompleted ? Colors.green : Colors.grey.shade400);

    return GestureDetector(
      onTap: isClickable
          ? () => _handleNavigation(context, state, () => context.read<WorkspaceCubit>().goToStep(step))
          : null,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.1)
                  : (isCompleted ? color : Colors.transparent),
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive
                      ? color
                      : (isCompleted ? Colors.white : color),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.black87 : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(int step, int maxReached) {
    final bool isCompleted = step < maxReached;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: isCompleted ? Colors.green : Colors.grey.shade300,
      ),
    );
  }
}
