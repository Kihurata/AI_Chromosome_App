import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/test_order.dart';
import '../shared/data_display/app_data_table.dart';
import '../shared/data_display/status_badge.dart';
import '../shared/form/app_buttons.dart';
import '../../../../domain/entities/specialist.dart';
import 'assign_specialist_dialog.dart';

class LabExaminationTable extends StatelessWidget {
  final bool isLoading;
  final List<TestOrder> orders;
  final List<Specialist> specialists;
  final String? focusedOrderId;

  const LabExaminationTable({
    super.key,
    required this.isLoading,
    required this.orders,
    required this.specialists,
    this.focusedOrderId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: AppDataTable(
        searchHint: 'Tìm kiếm xét nghiệm...',
        countText: '${orders.length} xét nghiệm',
        headerRow: const _HeaderRow(),
        isLoading: isLoading,
        rows: orders.map((order) => _OrderRow(
          order: order, 
          specialists: specialists,
          isFocused: order.id == focusedOrderId,
        )).toList(),
        emptyState: const Center(
          child: Text('Không có ca xét nghiệm nào'),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
    );
    return const Row(
      children: [
        Expanded(flex: 2, child: Text('ID-XN', style: style)),
        Expanded(flex: 3, child: Text('HỌ TÊN', style: style)),
        Expanded(flex: 3, child: Text('LOẠI XÉT NGHIỆM', style: style)),
        Expanded(flex: 3, child: Text('NGÀY CHỈ ĐỊNH', style: style)),
        Expanded(flex: 3, child: Text('BÁC SĨ CHỈ ĐỊNH', style: style)),
        Expanded(flex: 2, child: Text('TRẠNG THÁI', style: style)),
        Expanded(flex: 2, child: Text('THAO TÁC', style: style, textAlign: TextAlign.center)),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  final TestOrder order;
  final List<Specialist> specialists;
  final bool isFocused;

  const _OrderRow({
    required this.order, 
    required this.specialists,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isFocused ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // ID-XN
          Expanded(
            flex: 2,
            child: Text(
              '#LAB-${order.id.length > 4 ? order.id.substring(0, 4).toUpperCase() : order.id.toUpperCase()}',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // HỌ TÊN
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Mã BN: ${order.patientCode}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          // LOẠI XÉT NGHIỆM
          const Expanded(
            flex: 3,
            child: Text('Phân tích Karyotype'),
          ),
          
          // NGÀY CHỈ ĐỊNH
          Expanded(
            flex: 3,
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          
          // BÁC SĨ CHỈ ĐỊNH
          Expanded(
            flex: 3,
            child: Text(
              order.specialistId ?? 'Chưa chỉ định',
              style: TextStyle(
                fontStyle: order.specialistId == null ? FontStyle.italic : FontStyle.normal,
                color: order.specialistId == null ? AppColors.textPlaceholder : AppColors.textPrimary,
              ),
            ),
          ),
          
          // TRẠNG THÁI
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                text: _getStatusText(order.status),
                type: _getStatusType(order.status),
              ),
            ),
          ),
          
          // THAO TÁC
          Expanded(
            flex: 2,
            child: Center(
              child: _buildActionButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (order.status == TestOrderStatus.pending) {
      return AppPrimaryButton(
        text: 'Chỉ định BS',
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onPressed: () => _showAssignDialog(context),
      );
    } else if (order.status == TestOrderStatus.waitingApproval) {
      return AppPrimaryButton(
        text: 'Duyệt Kết quả',
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onPressed: () => context.push('/manager/review/${order.id}'),
      );
    } else if (order.status == TestOrderStatus.completed) {
       return AppSecondaryButton(
        text: 'Xem kết quả',
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onPressed: () => context.push('/manager/review/${order.id}'),
      );
    }
    return const SizedBox.shrink();
  }

  void _showAssignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignSpecialistDialog(order: order, specialists: specialists),
    );
  }

  String _getStatusText(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending:
        return 'CHỜ CHỈ ĐỊNH';
      case TestOrderStatus.culturing:
        return 'Đang nuôi cấy';
      case TestOrderStatus.analyzing:
        return 'Đang phân tích';
      case TestOrderStatus.waitingApproval:
        return 'CHỜ DUYỆT';
      case TestOrderStatus.completed:
        return 'ĐÃ HOÀN THÀNH';
      case TestOrderStatus.rejected:
        return 'YÊU CẦU LẠI';
    }
  }

  BadgeType _getStatusType(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending:
        return BadgeType.warning;
      case TestOrderStatus.culturing:
        return BadgeType.processing;
      case TestOrderStatus.analyzing:
        return BadgeType.processing;
      case TestOrderStatus.waitingApproval:
        return BadgeType.success;
      case TestOrderStatus.completed:
        return BadgeType.success;
      case TestOrderStatus.rejected:
        return BadgeType.danger;
    }
  }
}
