import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:medcore_crm/core/theme/app_colors.dart';
import 'package:medcore_crm/presentation/widgets/shared/data_display/app_data_table.dart';
import 'package:medcore_crm/presentation/widgets/shared/data_display/status_badge.dart';
import 'package:medcore_crm/logic/bloc/clinician/clinician_order_cubit.dart';
import 'package:medcore_crm/logic/bloc/clinician/clinician_order_state.dart';
import 'package:medcore_crm/domain/entities/test_order.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class TestResultsTab extends StatefulWidget {
  final String patientId;
  const TestResultsTab({super.key, required this.patientId});

  @override
  State<TestResultsTab> createState() => _TestResultsTabState();
}

class _TestResultsTabState extends State<TestResultsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ClinicianOrderCubit>().listenToAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicianOrderCubit, ClinicianOrderState>(
      builder: (context, state) {
        if (state is ClinicianOrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TestOrdersLoaded) {
          final patientOrders = state.testOrders.where((o) => o.patientId == widget.patientId).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Danh sách Xét nghiệm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 500,
                child: AppDataTable(
                  searchHint: 'Tìm kiếm xét nghiệm...',
                  countText: '${patientOrders.length} xét nghiệm',
                  headerRow: const _HeaderRow(),
                  rows: patientOrders.map((order) => _OrderRow(order: order)).toList(),
                  emptyState: _buildEmptyState(),
                  isLoading: false,
                ),
              ),
            ],
          );
        }

        if (state is ClinicianOrderError) {
          return Center(child: Text('Lỗi: ${state.message}'));
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.flaskConical, size: 64, color: AppColors.border.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Chưa có dữ liệu xét nghiệm',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
    );
    return const Row(
      children: [
        Expanded(flex: 2, child: Text('ID XÉT NGHIỆM', style: style)),
        Expanded(flex: 3, child: Text('NGÀY TẠO', style: style)),
        Expanded(flex: 3, child: Text('TRẠNG THÁI', style: style)),
        Expanded(flex: 2, child: Text('THAO TÁC', style: style, textAlign: TextAlign.center)),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  final TestOrder order;
  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              order.patientCode,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                text: _getStatusText(order.status),
                type: _getStatusType(order.status),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: IconButton(
                icon: const Icon(LucideIcons.eye, size: 18, color: AppColors.primaryBlue),
                onPressed: () => context.push('/clinician/test-result/${order.id}'),
                tooltip: 'Xem chi tiết',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(TestOrderStatus status) {
    switch (status) {
      case TestOrderStatus.pending:
        return 'CHỜ XỬ LÝ';
      case TestOrderStatus.culturing:
        return 'ĐANG NUÔI CẤY';
      case TestOrderStatus.analyzing:
        return 'ĐANG PHÂN TÍCH';
      case TestOrderStatus.waitingApproval:
        return 'CHỜ DUYỆT';
      case TestOrderStatus.completed:
        return 'HOÀN TẤT';
      case TestOrderStatus.rejected:
        return 'BỊ TỪ CHỐI';
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
        return BadgeType.warning;
      case TestOrderStatus.completed:
        return BadgeType.success;
      case TestOrderStatus.rejected:
        return BadgeType.danger;
    }
  }
}
