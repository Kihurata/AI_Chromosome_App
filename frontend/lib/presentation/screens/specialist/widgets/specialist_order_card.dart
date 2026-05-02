import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../logic/bloc/specialist/specialist_dashboard_cubit.dart';
import 'package:go_router/go_router.dart';

class SpecialistOrderCard extends StatelessWidget {
  final TestOrder order;

  const SpecialistOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(order.status), color: _getStatusColor(order.status), size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.patientName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã phiếu: ${order.patientCode}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(context, order.status),
              ],
            ),
            const SizedBox(width: 40),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TestOrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: _getStatusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (order.status == TestOrderStatus.pending) {
      return ElevatedButton.icon(
        onPressed: () => _showStartAnalysisConfirm(context),
        icon: const Icon(LucideIcons.play, size: 16),
        label: const Text('Bắt đầu phân tích'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    
    if (order.status == TestOrderStatus.analyzing) {
      return OutlinedButton.icon(
        onPressed: () {
          context.goNamed('specialist-analysis', pathParameters: {'orderId': order.id});
        },
        icon: const Icon(LucideIcons.externalLink, size: 16),
        label: const Text('Tiếp tục'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return const SizedBox(width: 140);
  }

  void _showStartAnalysisConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận bắt đầu'),
        content: Text('Bạn có chắc chắn muốn bắt đầu phân tích phiếu của bệnh nhân ${order.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SpecialistDashboardCubit>().startOrderAnalysis(order.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Bắt đầu'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending: return Colors.orange;
      case TestOrderStatus.analyzing: return Colors.indigo;
      case TestOrderStatus.completed: return Colors.green;
      case TestOrderStatus.rejected: return Colors.red;
      case TestOrderStatus.waitingApproval: return Colors.purple;
    }
  }

  IconData _getStatusIcon(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending: return LucideIcons.clock;
      case TestOrderStatus.analyzing: return LucideIcons.activity;
      case TestOrderStatus.completed: return LucideIcons.checkCircle;
      case TestOrderStatus.rejected: return LucideIcons.xCircle;
      case TestOrderStatus.waitingApproval: return LucideIcons.eye;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
