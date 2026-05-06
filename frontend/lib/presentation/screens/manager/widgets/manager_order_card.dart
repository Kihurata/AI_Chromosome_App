import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../domain/entities/specialist.dart';

class ManagerOrderCard extends StatelessWidget {
  final TestOrder order;
  final List<Specialist> specialists;
  final Function(String specialistId) onAssign;
  final VoidCallback? onApprove;
  final Function(String reason)? onReject;

  const ManagerOrderCard({
    super.key,
    required this.order,
    required this.specialists,
    required this.onAssign,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 20),
          Expanded(child: _buildOrderInfo()),
          const SizedBox(width: 20),
          _buildActionSection(context),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              order.patientName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                order.patientCode,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF495057),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(LucideIcons.calendar, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              'Tạo ngày: ${_formatDate(order.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            if (order.specialistId != null) ...[
              const SizedBox(width: 16),
              Icon(LucideIcons.user, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Kỹ thuật viên: ${_getSpecialistName()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    switch (order.status) {
      case TestOrderStatus.pending:
        return ElevatedButton.icon(
          onPressed: () => _showAssignDialog(context),
          icon: const Icon(LucideIcons.userPlus, size: 16),
          label: const Text('Phân công'),
          style: _buttonStyle(const Color(0xFF007BFF)),
        );
      case TestOrderStatus.waitingApproval:
        return Row(
          children: [
            OutlinedButton(
              onPressed: () => _showRejectDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Từ chối'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onApprove,
              style: _buttonStyle(const Color(0xFF28A745)),
              child: const Text('Phê duyệt'),
            ),
          ],
        );
      case TestOrderStatus.analyzing:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Đang thực hiện...',
            style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phân công chuyên viên'),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: specialists.length,
            itemBuilder: (context, index) {
              final s = specialists[index];
              return ListTile(
                leading: CircleAvatar(child: Text(s.fullName[0])),
                title: Text(s.fullName),
                subtitle: Text('Đang xử lý: ${s.activeWorkload} phiếu'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  onAssign(s.id);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lý do từ chối'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nhập nội dung phản hồi cho Specialist...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              onReject?.call(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
      case TestOrderStatus.pending: return const Color(0xFF007BFF);
      case TestOrderStatus.culturing: return const Color(0xFFF59E0B); // Amber
      case TestOrderStatus.analyzing: return const Color(0xFFFD7E14);
      case TestOrderStatus.waitingApproval: return const Color(0xFF6F42C1);
      case TestOrderStatus.completed: return const Color(0xFF28A745);
      case TestOrderStatus.rejected: return const Color(0xFFDC3545);
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case TestOrderStatus.pending: return LucideIcons.userPlus;
      case TestOrderStatus.culturing: return LucideIcons.flaskConical;
      case TestOrderStatus.analyzing: return LucideIcons.activity;
      case TestOrderStatus.waitingApproval: return LucideIcons.clipboardCheck;
      case TestOrderStatus.completed: return LucideIcons.checkCircle2;
      case TestOrderStatus.rejected: return LucideIcons.xCircle;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _getSpecialistName() {
    final s = specialists.cast<Specialist?>().firstWhere((s) => s?.id == order.specialistId, orElse: () => null);
    return s?.fullName ?? 'N/A';
  }
}
