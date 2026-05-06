import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:medcore_crm/core/theme/app_colors.dart';
import 'package:medcore_crm/domain/entities/patient.dart';
import 'package:intl/intl.dart';

class PatientInfoTab extends StatelessWidget {
  final Patient patient;
  const PatientInfoTab({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information Section
        _buildSectionHeader('Thông tin Cá nhân', LucideIcons.user),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 32,
          crossAxisSpacing: 32,
          childAspectRatio: 3,
          children: [
            _buildInfoItem('HỌ VÀ TÊN', patient.fullName),
            _buildInfoItem('GIỚI TÍNH', patient.gender),
            _buildInfoItem('NGÀY SINH', DateFormat('dd/MM/yyyy').format(patient.dob)),
            _buildInfoItem('SỐ ĐIỆN THOẠI', patient.phone),
            _buildInfoItem('CĂN CƯỚC CÔNG DÂN', patient.identityCard.isNotEmpty ? patient.identityCard : 'Chưa cập nhật'),
            _buildInfoItem('MÃ BỆNH NHÂN', patient.patientCode ?? 'N/A'),
          ],
        ),
        
        const SizedBox(height: 48),
        
        // Contact Information Section
        _buildSectionHeader('Thông tin Liên lạc & Địa chỉ', LucideIcons.mapPin),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 32,
          crossAxisSpacing: 32,
          childAspectRatio: 3,
          children: [
            _buildInfoItem('ĐỊA CHỈ', patient.address.isNotEmpty ? patient.address : 'Chưa cập nhật'),
            _buildInfoItem('PHƯỜNG/XÃ', patient.ward.isNotEmpty ? patient.ward : 'Chưa cập nhật'),
            _buildInfoItem('QUẬN/HUYỆN', patient.district.isNotEmpty ? patient.district : 'Chưa cập nhật'),
            _buildInfoItem('TỈNH/THÀNH PHỐ', patient.province.isNotEmpty ? patient.province : 'Chưa cập nhật'),
          ],
        ),
        
        const SizedBox(height: 48),
        
        // Emergency Contact Section
        _buildSectionHeader('Liên hệ Khẩn cấp', LucideIcons.phoneCall),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 32,
          crossAxisSpacing: 32,
          childAspectRatio: 3,
          children: [
            _buildInfoItem('NGƯỜI LIÊN HỆ', patient.emergencyContactName.isNotEmpty ? patient.emergencyContactName : 'Chưa cập nhật'),
            _buildInfoItem('SĐT KHẨN CẤP', patient.emergencyContactPhone.isNotEmpty ? patient.emergencyContactPhone : 'Chưa cập nhật'),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
