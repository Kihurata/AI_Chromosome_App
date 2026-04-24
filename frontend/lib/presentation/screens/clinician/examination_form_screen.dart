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
      formContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            icon: LucideIcons.user,
            title: 'THÔNG TIN HÀNH CHÍNH',
            actionText: 'Chi tiết hồ sơ',
            child: Row(
              children: [
                Expanded(child: _buildReadOnlyField('MÃ BỆNH NHÂN', 'BN-99201')),
                Expanded(child: _buildReadOnlyField('HỌ VÀ TÊN', 'TRẦN THỊ THANH THẢO', textColor: AppColors.primaryBlue)),
                Expanded(child: _buildReadOnlyField('NGÀY SINH / TUỔI', '12/05/1988 (35t)')),
                Expanded(child: _buildReadOnlyField('GIỚI TÍNH', 'Nữ')),
              ],
            ),
            bottomChild: Row(
              children: [
                Expanded(flex: 2, child: _buildReadOnlyField('ĐỊA CHỈ', '123 Lê Lợi, Phường Bến Thành, Quận 1, TP.HCM')),
                Expanded(child: _buildReadOnlyField('SỐ ĐIỆN THOẠI', '0901 234 567')),
                Expanded(child: _buildReadOnlyField('SỐ BHYT', 'GD-4-79-79-001-00001')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: LucideIcons.stethoscope,
            title: 'NỘI DUNG CHUYÊN MÔN',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubTitle('TRIỆU CHỨNG LÂM SÀNG'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Vị trí đau/khó chịu', 'Vùng thượng vị, ngực trái...')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField('Thời gian bị', '2 ngày trước, kéo dài 10p...')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDropdownField('Mức độ đau (1-10)', '5 - Trung bình')),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSubTitle('TIỀN SỬ & DỊ ỨNG'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildInputField('Bệnh nền', 'Tiểu đường, cao huyết áp...', maxLines: 3)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField('Dị ứng', 'Thuốc kháng sinh, hải sản...', maxLines: 3)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField('Thuốc đang dùng', 'Tên thuốc, liều dùng...', maxLines: 3)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildInputField('CHẨN ĐOÁN SƠ BỘ', 'Nhập chẩn đoán sơ bộ...')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSearchField('CHẨN ĐOÁN CHÍNH (ICD-10)', 'Tìm mã bệnh ICD-10...')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: LucideIcons.pill,
            title: 'KẾT LUẬN & ĐIỀU TRỊ',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInputField('KẾT LUẬN BỆNH', 'Tóm tắt tình trạng và kết luận...', maxLines: 3)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField('HƯỚNG ĐIỀU TRỊ & DẶN DÒ', 'Chế độ ăn uống, sinh hoạt, cách dùng thuốc...', maxLines: 3)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ĐƠN THUỐC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                            ),
                            // In real app, make it dashed border
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(LucideIcons.plusCircle, color: AppColors.textSecondary, size: 24),
                                SizedBox(height: 8),
                                Text('Click để thêm thuốc từ danh mục', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildInputField('HẸN TÁI KHÁM', 'dd/mm/yyyy', suffixIcon: LucideIcons.calendar)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Ưu tiên tái khám', style: TextStyle(color: AppColors.textPrimary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInputField('GHI CHÚ THUỐC', 'Ghi chú thêm về đơn thuốc...', maxLines: 3),
              ],
            ),
          ),
        ],
      ),
      bottomActions: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: () => context.go('/clinician/medical-record/$id'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerText,
              side: const BorderSide(color: AppColors.dangerText),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hủy khám'),
          ),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/clinician/blood-test-prescription/$id');
                },
                icon: const Icon(LucideIcons.flaskConical, size: 18),
                label: const Text('Lập Phiếu CĐXN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B), // Dark Navy
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/clinician/medical-record/$id'),
                icon: const Icon(LucideIcons.save, size: 18),
                label: const Text('Lưu thông tin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, String? actionText, required Widget child, Widget? bottomChild}) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              if (actionText != null)
                Text(actionText, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          child,
          if (bottomChild != null) ...[
            const SizedBox(height: 24),
            bottomChild,
          ]
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {Color textColor = AppColors.textPrimary}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSubTitle(String title) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1, IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
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

  Widget _buildSearchField(String label, String hint) {
    return _buildInputField(label, hint, suffixIcon: LucideIcons.search);
  }

  Widget _buildDropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
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
