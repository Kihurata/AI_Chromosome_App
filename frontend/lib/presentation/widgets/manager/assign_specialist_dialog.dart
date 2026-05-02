import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../logic/bloc/manager/manager_dashboard_cubit.dart';

class AssignSpecialistDialog extends StatefulWidget {
  final TestOrder order;

  const AssignSpecialistDialog({super.key, required this.order});

  @override
  State<AssignSpecialistDialog> createState() => _AssignSpecialistDialogState();
}

class _AssignSpecialistDialogState extends State<AssignSpecialistDialog> {
  String? selectedSpecialistId;

  // Mock specialist data
  final List<Map<String, dynamic>> specialists = [
    {
      'id': 'spec_01',
      'name': 'CV. Trần Văn An',
      'specialty': 'Di truyền phân tử',
      'workload': 3,
      'status': 'warning',
    },
    {
      'id': 'spec_02',
      'name': 'CV. Lê Thị Thu',
      'specialty': 'Phân tích Karyotype',
      'workload': 1,
      'status': 'success',
    },
    {
      'id': 'spec_03',
      'name': 'CV. Phạm Hoàng Dũng',
      'specialty': 'Tế bào học',
      'workload': 5,
      'status': 'danger',
    },
  ];

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
            ...specialists.map((spec) => _buildSpecialistItem(spec)),

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
                ElevatedButton(
                  onPressed: selectedSpecialistId == null
                      ? null
                      : () {
                          context.read<ManagerDashboardCubit>().assignSpecialist(
                                orderId: widget.order.id,
                                specialistId: selectedSpecialistId!,
                              );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: AppColors.border,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Xác nhận chỉ định', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistItem(Map<String, dynamic> spec) {
    bool isSelected = selectedSpecialistId == spec['id'];
    return GestureDetector(
      onTap: () => setState(() => selectedSpecialistId = spec['id']),
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
            CircleAvatar(
              backgroundColor: const Color(0xFFF3F4F6),
              child: const Icon(LucideIcons.user, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(spec['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(spec['specialty'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            _buildWorkloadBadge(spec['workload'], spec['status']),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadBadge(int count, String status) {
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
