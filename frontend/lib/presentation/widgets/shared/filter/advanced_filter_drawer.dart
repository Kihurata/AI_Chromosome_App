import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/filter_options.dart';
import '../form/app_buttons.dart';

class AppAdvancedFilterDrawer extends StatelessWidget {
  final AppSortOrder currentSortOrder;
  final ValueChanged<AppSortOrder> onSortOrderChanged;
  final AppDateRangePreset currentDateRange;
  final ValueChanged<AppDateRangePreset> onDateRangeChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const AppAdvancedFilterDrawer({
    super.key,
    required this.currentSortOrder,
    required this.onSortOrderChanged,
    required this.currentDateRange,
    required this.onDateRangeChanged,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionTitle('Sắp xếp theo thời gian'),
                const SizedBox(height: 16),
                _buildSortOptions(),
                const SizedBox(height: 32),
                _buildSectionTitle('Khoảng thời gian'),
                const SizedBox(height: 16),
                _buildDateRangeOptions(),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bộ lọc nâng cao',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: [
        _buildRadioOption<AppSortOrder>(
          title: 'Mới nhất',
          value: AppSortOrder.newest,
          groupValue: currentSortOrder,
          onChanged: (v) => onSortOrderChanged(v!),
        ),
        _buildRadioOption<AppSortOrder>(
          title: 'Cũ nhất',
          value: AppSortOrder.oldest,
          groupValue: currentSortOrder,
          onChanged: (v) => onSortOrderChanged(v!),
        ),
      ],
    );
  }

  Widget _buildDateRangeOptions() {
    return Column(
      children: [
        _buildRadioOption<AppDateRangePreset>(
          title: 'Tất cả',
          value: AppDateRangePreset.all,
          groupValue: currentDateRange,
          onChanged: (v) => onDateRangeChanged(v!),
        ),
        _buildRadioOption<AppDateRangePreset>(
          title: 'Hôm nay',
          value: AppDateRangePreset.today,
          groupValue: currentDateRange,
          onChanged: (v) => onDateRangeChanged(v!),
        ),
        _buildRadioOption<AppDateRangePreset>(
          title: '7 ngày qua',
          value: AppDateRangePreset.last7Days,
          groupValue: currentDateRange,
          onChanged: (v) => onDateRangeChanged(v!),
        ),
        _buildRadioOption<AppDateRangePreset>(
          title: '30 ngày qua',
          value: AppDateRangePreset.last30Days,
          groupValue: currentDateRange,
          onChanged: (v) => onDateRangeChanged(v!),
        ),
        _buildRadioOption<AppDateRangePreset>(
          title: 'Tùy chỉnh',
          value: AppDateRangePreset.custom,
          groupValue: currentDateRange,
          onChanged: (v) => onDateRangeChanged(v!),
        ),
      ],
    );
  }

  Widget _buildRadioOption<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          AppPrimaryButton(
            text: 'Áp dụng',
            width: double.infinity,
            onPressed: () {
              onApply();
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          AppSecondaryButton(
            text: 'Xóa bộ lọc',
            width: double.infinity,
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
