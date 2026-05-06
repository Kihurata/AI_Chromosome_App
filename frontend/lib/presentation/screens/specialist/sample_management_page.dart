import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../logic/bloc/specialist/sample_management_cubit.dart';
import '../../../../logic/bloc/specialist/sample_management_state.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/sample_card.dart';

class SampleManagementPage extends StatefulWidget {
  const SampleManagementPage({super.key});

  @override
  State<SampleManagementPage> createState() => _SampleManagementPageState();
}

class _SampleManagementPageState extends State<SampleManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<SampleManagementCubit>().loadSamples();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilterBar(),
            const SizedBox(height: 24),
            Expanded(child: _buildSampleList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quản lý Mẫu Bệnh phẩm',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Theo dõi tiến độ nuôi cấy và tải ảnh metaphase hàng loạt.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return BlocBuilder<SampleManagementCubit, SampleManagementState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Tất cả',
                isSelected: state.filterStatus == null,
                onSelected: () => context.read<SampleManagementCubit>().setFilter(null),
              ),
              const SizedBox(width: 12),
              _FilterChip(
                label: 'Mới thu nhận',
                isSelected: state.filterStatus == SampleStatus.collected,
                onSelected: () => context.read<SampleManagementCubit>().setFilter(SampleStatus.collected),
              ),
              const SizedBox(width: 12),
              _FilterChip(
                label: 'Đang nuôi cấy',
                isSelected: state.filterStatus == SampleStatus.culturing,
                onSelected: () => context.read<SampleManagementCubit>().setFilter(SampleStatus.culturing),
              ),
              const SizedBox(width: 12),
              _FilterChip(
                label: 'Đã thu hoạch',
                isSelected: state.filterStatus == SampleStatus.harvested,
                onSelected: () => context.read<SampleManagementCubit>().setFilter(SampleStatus.harvested),
              ),
              const SizedBox(width: 12),
              _FilterChip(
                label: 'Thất bại',
                isSelected: state.filterStatus == SampleStatus.failed,
                onSelected: () => context.read<SampleManagementCubit>().setFilter(SampleStatus.failed),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSampleList() {
    return BlocBuilder<SampleManagementCubit, SampleManagementState>(
      builder: (context, state) {
        if (state.status == SampleManagementStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.filteredSamples.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 64),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Không tìm thấy mẫu nào',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header row ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Mã mẫu & Loại',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6B7280), letterSpacing: 0.3),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Bệnh nhân',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6B7280), letterSpacing: 0.3),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Ngày thu nhận',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6B7280), letterSpacing: 0.3),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Trạng thái',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6B7280), letterSpacing: 0.3),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Hành động',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6B7280), letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Data rows ────────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  itemCount: state.filteredSamples.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final sample = state.filteredSamples[index];
                    return SampleCard(
                      sample: sample,
                      onStatusUpdate: (status) {
                        context.read<SampleManagementCubit>().updateStatus(sample.id, status);
                      },
                      onFailure: (reason) {
                        context.read<SampleManagementCubit>().updateNote(sample.id, reason);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
