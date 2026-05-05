import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../logic/bloc/specialist/specialist_dashboard_cubit.dart';
import '../../../../core/router/app_router.dart';

class SpecialistOrderCard extends StatelessWidget {
  final TestOrder order;

  const SpecialistOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('${AppRoutes.specialistSamples}/${order.id}'),
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
              flex: 3,
              child: Text(
                _getTestTypeName(order.status),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
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
            // ── Hành động ──────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Center(
                child: _buildActionCell(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCell(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusBadge(order.status),
        const SizedBox(width: 12),
        _buildActionButton(context),
      ],
    );
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
      return ElevatedButton.icon(
        onPressed: () => _showStartAnalysisConfirm(context),
        icon: const Icon(LucideIcons.play, size: 14),
        label: const Text('Bắt đầu'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    if (order.status == TestOrderStatus.analyzing) {
      return OutlinedButton.icon(
        onPressed: () {
          context.goNamed('specialist-analysis',
              pathParameters: {'orderId': order.id});
        },
        icon: const Icon(LucideIcons.externalLink, size: 14),
        label: const Text('Tiếp tục'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return const SizedBox(width: 80);
  }

  void _showStartAnalysisConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận bắt đầu'),
        content: Text(
            'Bạn có chắc chắn muốn bắt đầu phân tích phiếu của bệnh nhân ${order.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<SpecialistDashboardCubit>()
                  .startOrderAnalysis(order.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Bắt đầu'),
          ),
        ],
      ),
    );
  }

  // Placeholder: map status to a test type label (real data would come from order entity)
  String _getTestTypeName(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending:
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
      case TestOrderStatus.analyzing:
        return Colors.indigo;
      case TestOrderStatus.completed:
        return Colors.green;
      case TestOrderStatus.rejected:
        return Colors.red;
      case TestOrderStatus.waitingApproval:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
