import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/layouts/medical_record_layout.dart';
import '../../../widgets/shared/data_display/status_badge.dart';

class ClinicianMedicalRecordPage extends StatefulWidget {
  final String id;
  const ClinicianMedicalRecordPage({super.key, required this.id});

  @override
  State<ClinicianMedicalRecordPage> createState() => _ClinicianMedicalRecordPageState();
}

class _ClinicianMedicalRecordPageState extends State<ClinicianMedicalRecordPage> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MedicalRecordLayout(
      title: 'Bệnh án Điện tử',
      headerAction: ElevatedButton.icon(
        onPressed: () {
          context.push('/clinician/examination-form/${widget.id}');
        },
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Lập TTKB'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      breadcrumbText: 'Johnathan Doe',
      onBreadcrumbTap: () => context.go('/clinician/appointments'),
      profileSection: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
            // Placeholder for avatar
            child: const Icon(LucideIcons.user, color: AppColors.textSecondary, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Johnathan Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(LucideIcons.mail, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text('j.doe@hospital.com', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: const [
                  Icon(LucideIcons.phone, size: 14, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text('+1 (555) 234-5678', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          )
        ],
      ),
      tabTitles: const ['Thông tin Chi tiết', 'Lịch sử Khám bệnh', 'Kết quả Xét nghiệm'],
      activeTabIndex: _activeTabIndex,
      onTabChanged: (index) {
        setState(() {
          _activeTabIndex = index;
        });
      },
      tabBody: _buildTabBody(),
    );
  }

  Widget _buildTabBody() {
    if (_activeTabIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thông tin chung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              TextButton(
                onPressed: () {},
                child: const Text('Cập nhật thông tin', style: TextStyle(color: AppColors.primaryBlue)),
              )
            ],
          ),
          const Divider(height: 32, color: AppColors.border),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('HỌ VÀ TÊN', 'Johnathan Doe Richardson'),
                    const SizedBox(height: 24),
                    _buildInfoItem('SỐ ĐIỆN THOẠI', '+1 (555) 234-5678'),
                    const SizedBox(height: 24),
                    _buildInfoItem('TRẠNG THÁI VIP', 'Hoạt động (Ưu tiên 1)', iconColor: Colors.orange),
                    const SizedBox(height: 24),
                    _buildInfoItem('NGÀY KHÁM ĐẦU TIÊN', 'March 12, 2022'),
                    const SizedBox(height: 24),
                    _buildInfoItem('NGÀY KHÁM GẦN NHẤT', 'October 05, 2023'),
                    const SizedBox(height: 24),
                    _buildInfoItem('LỊCH HẸN TIẾP THEO', 'November 12, 2023 - 10:30 AM', textColor: AppColors.primaryBlue, isBold: true),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('NGÀY SINH', '24 tháng 7, 1988 (35 tuổi)'),
                    const SizedBox(height: 24),
                    _buildInfoItem('GIỚI TÍNH', 'Nam'),
                    const SizedBox(height: 24),
                    _buildInfoItem('MÃ Y TẾ', 'ID-8824-7712-XXX'),
                  ],
                ),
              ),
            ],
          )
        ],
      );
    } else if (_activeTabIndex == 1) {
      return const Center(child: Text('Lịch sử khám bệnh (Đang xây dựng)', style: TextStyle(color: AppColors.textSecondary)));
    } else {
      return const Center(child: Text('Kết quả xét nghiệm (Đang xây dựng)', style: TextStyle(color: AppColors.textSecondary)));
    }
  }

  Widget _buildInfoItem(String label, String value, {Color? iconColor, Color textColor = AppColors.textPrimary, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (iconColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: textColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }
}
