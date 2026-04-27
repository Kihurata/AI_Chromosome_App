import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../navigation/app_header.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MedicalRecordLayout extends StatelessWidget {
  final String title;
  final Widget? headerAction;
  final String breadcrumbText;
  final VoidCallback? onBreadcrumbTap;
  final Widget profileSection;
  final List<String> tabTitles;
  final int activeTabIndex;
  final ValueChanged<int> onTabChanged;
  final Widget tabBody;

  const MedicalRecordLayout({
    super.key,
    required this.title,
    this.headerAction,
    required this.breadcrumbText,
    this.onBreadcrumbTap,
    required this.profileSection,
    required this.tabTitles,
    required this.activeTabIndex,
    required this.onTabChanged,
    required this.tabBody,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header
        AppHeader(
          title: title,
          subtitle: '',
          actions: headerAction != null ? [headerAction!] : null,
        ),
        
        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBreadcrumbTap,
                      child: const Text(
                        'Lịch Khám',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textSecondary),
                    ),
                    Text(
                      breadcrumbText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Profile Section Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: profileSection,
                ),
                const SizedBox(height: 24),
                
                // Tabs
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: List.generate(tabTitles.length, (index) {
                      final isActive = index == activeTabIndex;
                      return GestureDetector(
                        onTap: () => onTabChanged(index),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 12, right: 32),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive ? AppColors.primaryBlue : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            tabTitles[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tab Content Body
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: tabBody,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
