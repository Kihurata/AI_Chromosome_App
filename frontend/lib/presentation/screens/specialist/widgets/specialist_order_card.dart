import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../core/router/app_router.dart';

class SpecialistOrderCard extends StatelessWidget {
  final TestOrder order;

  const SpecialistOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed('specialist-sample-detail', pathParameters: {'id': order.id}),
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
            // ── Trạng thái ──────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Center(
                child: _buildStatusBadge(order.status),
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
    // Chỉ hiện nút Phân tích AI nếu status là analyzing
    if (order.status == TestOrderStatus.analyzing) {
      return _buildActionButton(context);
    }
    return const SizedBox.shrink();
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
    return ElevatedButton(
      onPressed: () {
        // AC-5: navigate thẳng vào Workspace
        context.goNamed('specialist-analysis',
            pathParameters: {'orderId': order.id});
      },
      child: const Text('Phân tích AI'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
