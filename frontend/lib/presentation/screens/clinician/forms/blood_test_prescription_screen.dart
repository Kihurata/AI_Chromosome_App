import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/layouts/main_form_layout.dart';
import '../../../widgets/shared/form/app_text_field.dart';
import '../../../widgets/shared/form/app_buttons.dart';
import '../../../widgets/shared/form/app_dropdown.dart';

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
                  Expanded(
                    child: AppTextField(
                      labelText: 'Bệnh nhân',
                      hintText: 'Tìm kiếm bệnh nhân...',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDropdown<String>(
                      labelText: 'Loại xét nghiệm',
                      hintText: 'Chọn loại xét nghiệm',
                      items: const ['Xét nghiệm máu', 'Xét nghiệm nước tiểu']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (_) {},
                    ),
                  ),
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
                      Expanded(
                        child: AppDropdown<String>(
                          labelText: 'Loại mẫu',
                          value: 'Máu',
                          items: const ['Máu', 'Nước tiểu', 'Khác']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (_) {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          labelText: 'Thời gian lấy mẫu',
                          hintText: '10/25/2023, 08:00 AM',
                          suffixIcon: const Icon(LucideIcons.calendar, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    labelText: 'Ghi chú lâm sàng',
                    hintText: 'Nhập tóm tắt bệnh sử, chẩn đoán sơ bộ...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── BOTTOM ACTIONS ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppSecondaryButton(
                  text: 'Hủy',
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 12),
                AppPrimaryButton(
                  text: 'Lưu',
                  icon: LucideIcons.save,
                  onPressed: () => context.pop(),
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

}
