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
    return BlocListener<AiAnalysisCubit, AiAnalysisState>(
      listener: (context, state) {
        if (state is AiAnalysisCompleted) {
          context.read<WorkspaceCubit>().goToStep(3);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI hoàn tất! Đang chuyển sang lập NST đồ...'),
              backgroundColor: Colors.green,
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      _buildStepIndicator(1, 'Sàng lọc', state.currentStep, state.maxReachedStep, context),
                      _buildLine(1, state.maxReachedStep),
                      _buildStepIndicator(2, 'Tách NST', state.currentStep, state.maxReachedStep, context),
                      _buildLine(2, state.maxReachedStep),
                      _buildStepIndicator(3, 'Lập NST đồ', state.currentStep, state.maxReachedStep, context),
                      _buildLine(3, state.maxReachedStep),
                      _buildStepIndicator(4, 'Phê duyệt QC', state.currentStep, state.maxReachedStep, context),
                      _buildLine(4, state.maxReachedStep),
                      _buildStepIndicator(5, 'Báo cáo', state.currentStep, state.maxReachedStep, context),
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
                        onPressed: state.currentStep > 1 ? () => context.read<WorkspaceCubit>().previousStep() : null,
                      ),
                      AppPrimaryButton(
                        text: 'Tiếp tục',
                        onPressed: canProceed ? () => context.read<WorkspaceCubit>().nextStep() : null,
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, int currentStep, int maxReached, BuildContext context) {
    final bool isActive = step == currentStep;
    final bool isCompleted = step < currentStep || step <= maxReached;
    final bool isClickable = step <= maxReached;

    final Color color = isActive 
        ? Theme.of(context).primaryColor 
        : (isCompleted ? Colors.green : Colors.grey.shade400);

    return GestureDetector(
      onTap: isClickable ? () => context.read<WorkspaceCubit>().goToStep(step) : null,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? color.withValues(alpha: 0.1) : (isCompleted ? color : Colors.transparent),
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? color : (isCompleted ? Colors.white : color),
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
