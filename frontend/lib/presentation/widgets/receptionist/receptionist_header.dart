import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ReceptionistHeader extends StatelessWidget {
  final VoidCallback? onAddPatient;

  const ReceptionistHeader({super.key, this.onAddPatient});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Page Title
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bảng điều khiển Tiếp nhận',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'Quản lý lịch hẹn và tiếp nhận bệnh nhân',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),

          // Search
          SizedBox(
            width: 220,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bệnh nhân...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textPlaceholder),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textPlaceholder),
                filled: true,
                fillColor: AppColors.border.withAlpha(76),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Add Patient Button
          ElevatedButton.icon(
            onPressed: onAddPatient,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Thêm bệnh nhân', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),

          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary, size: 20),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.dangerText, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // User Avatar
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal[100],
                child: const Text('L', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lê Thị Lan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Lễ tân', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
