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
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── THÔNG TIN CHỈ ĐỊNH ────────────────────────────────────────
            _buildSection(
              icon: LucideIcons.fileSearch,
              title: 'THÔNG TIN CHỈ ĐỊNH',
              child: Row(
                children: [
                  Expanded(child: _input('Bệnh nhân', 'Tìm kiếm bệnh nhân...')),
                  const SizedBox(width: 16),
                  Expanded(child: _dropdown('Loại xét nghiệm', 'Chọn loại xét nghiệm')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── THÔNG TIN MẪU BỆNH PHẨM ──────────────────────────────────
            _buildSection(
              icon: LucideIcons.microscope,
              title: 'THÔNG TIN MẪU BỆNH PHẨM',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _dropdown('Loại mẫu', 'Máu (huyết thanh/huyết tương)')),
                      const SizedBox(width: 16),
                      Expanded(child: _input('Thời gian lấy mẫu', '10/25/2023, 08:00 AM', suffixIcon: LucideIcons.calendar)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _input('Ghi chú lâm sàng', 'Nhập tóm tắt bệnh sử, chẩn đoán sơ bộ...', maxLines: 4),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── BOTTOM ACTIONS ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(LucideIcons.save, size: 16),
                  label: const Text('Lưu'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _input(String label, String hint, {int maxLines = 1, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 12 : 13),
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.textSecondary, size: 16) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
