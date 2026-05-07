import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../logic/bloc/specialist/specialist_dashboard_cubit.dart';
import 'package:medcore_crm/presentation/widgets/shared/form/app_buttons.dart';
import '../../../../core/theme/app_colors.dart';

class SpecialistOrderCard extends StatelessWidget {
  final TestOrder order;
  final bool isFocused;

  const SpecialistOrderCard({
    super.key,
    required this.order,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.primaryBlue : Colors.grey.shade200,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.pushNamed(
          'specialist-sample-detail',
          pathParameters: {'id': order.id},
        ),
        hoverColor: Colors.blue.shade50.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // ── Bệnh nhân ──────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      order.patientName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.patientCode,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Xét nghiệm ─────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Text(
                  _getTestTypeName(order.status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              // ── Ngày yêu cầu ───────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Text(
                  _formatDate(order.createdAt),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
              // ── Trạng thái ──────────────────────────────────────────────
              Expanded(
                flex: 2,
                child: Center(child: _buildStatusBadge(order.status)),
              ),
              // ── Hành động ──────────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Center(child: _buildActionCell(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(BuildContext context) {
    // Hiện nút Phân Tích nếu đơn chưa hoàn thành/từ chối
    if (order.status != TestOrderStatus.completed &&
        order.status != TestOrderStatus.rejected) {
      return _buildActionButton(context);
    }
    return const SizedBox.shrink(); // This is fine as it's not the interactive part
  }

  Widget _buildStatusBadge(TestOrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (order.status == TestOrderStatus.pending) {
      return AppPrimaryButton(
        text: 'Bắt đầu phân tích',
        icon: LucideIcons.play,
        onPressed: () => _showStartAnalysisConfirm(context),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      );
    }

    if (order.status == TestOrderStatus.analyzing) {
      return AppSecondaryButton(
        text: 'Tiếp tục',
        icon: LucideIcons.externalLink,
        onPressed: () {
          context.goNamed(
            'specialist-analysis',
            pathParameters: {'orderId': order.id},
          );
        },
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      );
    }

    return const SizedBox(width: 140, height: 40);
  }

  void _showStartAnalysisConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận bắt đầu'),
        content: Text(
          'Bạn có chắc chắn muốn bắt đầu phân tích phiếu của bệnh nhân ${order.patientName}?',
        ),
        actions: [
          AppSecondaryButton(
            text: 'Hủy',
            onPressed: () => Navigator.pop(dialogContext),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          AppPrimaryButton(
            text: 'Bắt đầu',
            onPressed: () {
              context.read<SpecialistDashboardCubit>().startOrderAnalysis(
                order.id,
              );
              Navigator.pop(dialogContext);
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ],
      ),
    );
  }

  // Placeholder: map status to a test type label (real data would come from order entity)
  String _getTestTypeName(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending:
      case TestOrderStatus.culturing:
        return 'Xét nghiệm karyotype';
      case TestOrderStatus.analyzing:
        return 'Phân tích NST';
      case TestOrderStatus.completed:
        return 'Karyotype truyền thống';
      case TestOrderStatus.waitingApproval:
        return 'Phân tích SNP';
      case TestOrderStatus.rejected:
        return 'Xét nghiệm gen BRCA';
    }
  }

  Color _getStatusColor(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending:
        return Colors.orange;
      case TestOrderStatus.culturing:
        // AC-2: màu vàng nhạt/amber — dịu mắt, không cạnh tranh với CTA
        return Colors.amber.shade700;
      case TestOrderStatus.analyzing:
        return Colors.indigo;
      case TestOrderStatus.completed:
        return Colors.green;
      case TestOrderStatus.rejected:
        return Colors.red;
      case TestOrderStatus.waitingApproval:
        return const Color(0xFF7C3AED);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
