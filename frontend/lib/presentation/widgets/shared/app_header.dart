import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
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
              Text('Tổng quan của Bác sĩ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('Chào mừng trở lại, Bác sĩ Smith', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          
          // Search Input
          SizedBox(
            width: 250,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bệnh nhân hoặc hồ sơ',
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textPlaceholder),
                filled: true,
                fillColor: AppColors.border.withAlpha(76),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Add Patient CTA
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Thêm bệnh nhân'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 24),
          
          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.dangerText, shape: BoxShape.circle),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          
          // User Profile
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.teal[100],
                child: const Text('S', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. Smith', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('Bác sĩ Thần kinh', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
