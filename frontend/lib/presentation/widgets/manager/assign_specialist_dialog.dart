import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../logic/bloc/manager/manager_dashboard_cubit.dart';
import '../../widgets/shared/form/app_buttons.dart';


import '../../../../domain/entities/specialist.dart';


class AssignSpecialistDialog extends StatefulWidget {
  final TestOrder order;
  final List<Specialist> specialists;

  const AssignSpecialistDialog({
    super.key,
    required this.order,
    required this.specialists,
  });

  @override
  State<AssignSpecialistDialog> createState() => _AssignSpecialistDialogState();
}

class _AssignSpecialistDialogState extends State<AssignSpecialistDialog> {
  String? selectedSpecialistId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Chỉ định Chuyên viên Di truyền cho phiếu #ORD-${widget.order.id.substring(0, 4).toUpperCase()}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Mã BN: ', style: TextStyle(color: AppColors.textSecondary)),
                  TextSpan(text: widget.order.patientCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: '   Tên: ', style: TextStyle(color: AppColors.textSecondary)),
                  TextSpan(text: widget.order.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'DANH SÁCH CHUYÊN VIÊN KHẢ DỤNG',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Specialist List
            ...widget.specialists.map((spec) => _buildSpecialistItem(spec)),

            const SizedBox(height: 32),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                AppPrimaryButton(
                  text: 'Xác nhận chỉ định',
                  onPressed: selectedSpecialistId == null
                      ? null
                      : () {
                          context.read<ManagerDashboardCubit>().assignSpecialist(
                                orderId: widget.order.id,
                                specialistId: selectedSpecialistId!,
                              );
                          Navigator.pop(context);
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistItem(Specialist spec) {
    bool isSelected = selectedSpecialistId == spec.id;
    return GestureDetector(
      onTap: () => setState(() => selectedSpecialistId = spec.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.activeBackground : Colors.white,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(LucideIcons.user, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spec.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Chuyên viên Di truyền', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            _buildWorkloadBadge(spec.activeWorkload),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadBadge(int count) {
    String status;
    if (count <= 1) {
      status = 'success';
    } else if (count <= 4) {
      status = 'warning';
    } else {
      status = 'danger';
    }
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'success':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case 'warning':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'danger':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Text(
        'Đang xử lý $count phiếu',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
