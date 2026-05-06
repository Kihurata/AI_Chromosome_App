import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../logic/bloc/specialist/specialist_dashboard_cubit.dart';
import '../../../../logic/bloc/specialist/specialist_dashboard_state.dart';
import '../../../widgets/shared/form/app_text_field.dart';

class SpecialistFilterBar extends StatelessWidget {
  const SpecialistFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpecialistDashboardCubit, SpecialistDashboardState>(
      buildWhen: (p, c) => p.searchKeyword != c.searchKeyword || p.statusFilter != c.statusFilter,
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: AppTextField(
                hintText: 'Tìm kiếm theo tên hoặc mã bệnh nhân...',
                prefixIcon: LucideIcons.search,
                initialValue: state.searchKeyword,
                onChanged: (value) => context.read<SpecialistDashboardCubit>().setSearchKeyword(value),
              ),
            ),
            const SizedBox(width: 24),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(context, 'Tất cả', null, state.statusFilter == null),
                _buildFilterChip(context, 'Chờ xử lý', TestOrderStatus.pending, state.statusFilter == TestOrderStatus.pending),
                _buildFilterChip(context, 'Đang nuôi cấy', TestOrderStatus.culturing, state.statusFilter == TestOrderStatus.culturing),
                _buildFilterChip(context, 'Đang phân tích', TestOrderStatus.analyzing, state.statusFilter == TestOrderStatus.analyzing),
                _buildFilterChip(context, 'Chờ duyệt', TestOrderStatus.waitingApproval, state.statusFilter == TestOrderStatus.waitingApproval),
                _buildFilterChip(context, 'Hoàn thành', TestOrderStatus.completed, state.statusFilter == TestOrderStatus.completed),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, TestOrderStatus? status, bool isSelected) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<SpecialistDashboardCubit>().setStatusFilter(status),
      selectedColor: theme.primaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? theme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
