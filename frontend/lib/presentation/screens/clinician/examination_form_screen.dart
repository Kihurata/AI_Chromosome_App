import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/shared/layouts/main_form_layout.dart';

class ClinicianExaminationFormPage extends StatelessWidget {
  final String id;
  const ClinicianExaminationFormPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return MainFormLayout(
      title: 'PHIẾU KHÁM BỆNH',
      subtitle: 'Mã hồ sơ: #BK-2023-08942',
      showBackButton: false,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── THÔNG TIN HÀNH CHÍNH ──────────────────────────────────────
            _buildSection(
              icon: LucideIcons.user,
              title: 'THÔNG TIN HÀNH CHÍNH',
              actionText: 'Chi tiết hồ sơ',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _readOnly('MÃ BỆNH NHÂN', 'BN-99201')),
                      Expanded(child: _readOnly('HỌ VÀ TÊN', 'TRẦN THỊ THANH THẢO', textColor: AppColors.primaryBlue)),
                      Expanded(child: _readOnly('NGÀY SINH / TUỔI', '12/05/1988 (35t)')),
                      Expanded(child: _readOnly('GIỚI TÍNH', 'Nữ')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(flex: 2, child: _readOnly('ĐỊA CHỈ', '123 Lê Lợi, P.Bến Thành, Q.1, TP.HCM')),
                      Expanded(child: _readOnly('SỐ ĐIỆN THOẠI', '0901 234 567')),
                      Expanded(child: _readOnly('SỐ BHYT', 'GD-4-79-79-001-00001')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── NỘI DUNG CHUYÊN MÔN ──────────────────────────────────────
            _buildSection(
              icon: LucideIcons.stethoscope,
              title: 'NỘI DUNG CHUYÊN MÔN',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subTitle('TRIỆU CHỨNG LÂM SÀNG'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _input('Vị trí đau/khó chịu', 'Vùng thượng vị, ngực trái...')),
                      const SizedBox(width: 16),
                      Expanded(child: _input('Thời gian bị', '2 ngày trước, kéo dài 10p...')),
                      const SizedBox(width: 16),
                      Expanded(child: _dropdown('Mức độ đau (1-10)', '5 - Trung bình')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _subTitle('TIỀN SỬ & DỊ ỨNG'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _input('Bệnh nền', 'Tiểu đường, cao huyết áp...', maxLines: 3)),
                      const SizedBox(width: 16),
                      Expanded(child: _input('Dị ứng', 'Thuốc kháng sinh, hải sản...', maxLines: 3)),
                      const SizedBox(width: 16),
                      Expanded(child: _input('Thuốc đang dùng', 'Tên thuốc, liều dùng...', maxLines: 3)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _input('CHẨN ĐOÁN SƠ BỘ', 'Nhập chẩn đoán sơ bộ...')),
                      const SizedBox(width: 16),
                      Expanded(child: _input('CHẨN ĐOÁN CHÍNH (ICD-10)', 'Tìm mã bệnh ICD-10...', suffixIcon: LucideIcons.search)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── KẾT LUẬN & ĐIỀU TRỊ ──────────────────────────────────────
            _buildSection(
              icon: LucideIcons.pill,
              title: 'KẾT LUẬN & ĐIỀU TRỊ',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _input('KẾT LUẬN BỆNH', 'Tóm tắt tình trạng và kết luận...', maxLines: 3)),
                      const SizedBox(width: 16),
                      Expanded(child: _input('HƯỚNG ĐIỀU TRỊ & DẶN DÒ', 'Chế độ ăn uống, sinh hoạt...', maxLines: 3)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Đơn thuốc placeholder
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ĐƠN THUỐC',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            Container(
                              height: 90,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.plusCircle, color: AppColors.textSecondary, size: 22),
                                  SizedBox(height: 6),
                                  Text('Click để thêm thuốc từ danh mục',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Hẹn tái khám
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: _input('HẸN TÁI KHÁM', 'dd/mm/yyyy', suffixIcon: LucideIcons.calendar)),
                            const SizedBox(width: 16),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18, height: 18,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Ưu tiên tái khám',
                                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _input('GHI CHÚ THUỐC', 'Ghi chú thêm về đơn thuốc...', maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── BOTTOM ACTIONS ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/clinician/medical-record/$id'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerText,
                    side: const BorderSide(color: AppColors.dangerText),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Hủy khám'),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.push('/clinician/blood-test-prescription/$id'),
                      icon: const Icon(LucideIcons.flaskConical, size: 16),
                      label: const Text('Lập Phiếu CĐXN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/clinician/medical-record/$id'),
                      icon: const Icon(LucideIcons.save, size: 16),
                      label: const Text('Lưu thông tin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, String? actionText, required Widget child}) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(icon, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ]),
              if (actionText != null)
                Text(actionText, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _readOnly(String label, String value, {Color textColor = AppColors.textPrimary}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _subTitle(String title) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _input(String label, String hint, {int maxLines = 1, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
