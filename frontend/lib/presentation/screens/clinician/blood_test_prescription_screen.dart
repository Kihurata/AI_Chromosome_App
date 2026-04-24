import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/shared/layouts/main_form_layout.dart';

class ClinicianBloodTestPrescriptionPage extends StatelessWidget {
  final String id;
  const ClinicianBloodTestPrescriptionPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return MainFormLayout(
      title: 'Phiếu Chỉ định Xét nghiệm',
      subtitle: '',
      showBackButton: true,
      onBack: () => context.pop(), // Quay lại phiếu khám
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            icon: LucideIcons.fileSearch,
            title: 'THÔNG TIN CHỈ ĐỊNH',
            child: Row(
              children: [
                Expanded(child: _buildInputField('Bệnh nhân', 'Tìm kiếm bệnh nhân...')),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdownField('Loại xét nghiệm', 'Chọn loại xét nghiệm')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: LucideIcons.microscope,
            title: 'THÔNG TIN MẪU BỆNH PHẨM',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDropdownField('Loại mẫu', 'Máu (huyết thanh/huyết tương)')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField('Thời gian lấy mẫu', '10/25/2023, 08:00 AM', suffixIcon: LucideIcons.calendar)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField('Ghi chú lâm sàng', 'Nhập tóm tắt bệnh sử, chẩn đoán sơ bộ...', maxLines: 4),
              ],
            ),
          ),
        ],
      ),
      bottomActions: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hủy'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.save, size: 18),
            label: const Text('Lưu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 12 : 14),
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.textSecondary, size: 18) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}
