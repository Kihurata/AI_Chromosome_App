import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge({super.key, required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case BadgeType.success:
        bgColor = AppColors.successBg;
        textColor = AppColors.successText;
        break;
      case BadgeType.danger:
        bgColor = AppColors.dangerBg;
        textColor = AppColors.dangerText;
        break;
      case BadgeType.processing:
        bgColor = AppColors.processingBg;
        textColor = AppColors.processingText;
        break;
      case BadgeType.warning:
        bgColor = AppColors.warningBg;
        textColor = AppColors.warningText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum BadgeType { success, danger, processing, warning }
