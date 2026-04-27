import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/layouts/main_list_layout.dart';
import '../../../widgets/shared/data_display/status_badge.dart';

class ClinicianAppointmentListPage extends StatelessWidget {
  const ClinicianAppointmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainListLayout(
      title: 'Lịch Khám',
      subtitle: 'Danh sách lịch khám của bác sĩ',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Row
            Row(
              children: [
                const Text(
                  'Danh sách Lịch Khám',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Search field
                SizedBox(
                  width: 280,
                  height: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.search, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm tên, ID...',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 10),
                              hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(LucideIcons.filter, size: 16, color: AppColors.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Table
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerThickness: 1,
                  columns: const [
                    DataColumn(label: Text('ID - LK')),
                    DataColumn(label: Text('HỌ TÊN')),
                    DataColumn(label: Text('TUỔI')),
                    DataColumn(label: Text('GIỜ HẸN')),
                    DataColumn(label: Text('TRẠNG THÁI')),
                    DataColumn(label: Text('THAO TÁC')),
                  ],
                  rows: [
                    _buildRow(context, 'LK-001', 'Nguyễn Văn A', 35, '08:30', 'Chưa khám', BadgeType.warning),
                    _buildRow(context, 'LK-002', 'Trần Thị B', 28, '09:15', 'Đang khám', BadgeType.processing),
                    _buildRow(context, 'LK-003', 'Lê Văn D', 42, '10:00', 'Đã khám', BadgeType.success),
                    _buildRow(context, 'LK-004', 'Phạm Văn E', 31, '10:30', 'Chưa khám', BadgeType.warning),
                    _buildRow(context, 'LK-005', 'Hoàng Thị F', 26, '11:00', 'Đang khám', BadgeType.processing),
                    _buildRow(context, 'LK-006', 'Ngô Văn G', 50, '13:30', 'Đã khám', BadgeType.success),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Pagination
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('1/150', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(width: 12),
                _paginationBtn(LucideIcons.chevronLeft, () {}),
                const SizedBox(width: 4),
                _paginationBtn(LucideIcons.chevronRight, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginationBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, String id, String name, int age,
      String time, String statusLabel, BadgeType badgeType) {
    return DataRow(
      cells: [
        DataCell(Text(id,
            style: const TextStyle(
                color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
        DataCell(Text(name)),
        DataCell(Text('$age',
            style: const TextStyle(color: AppColors.textSecondary))),
        DataCell(Text(time)),
        DataCell(StatusBadge(text: statusLabel, type: badgeType)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionBtn(
              icon: LucideIcons.eye,
              color: AppColors.primaryBlue,
              bgColor: AppColors.activeBackground,
              tooltip: 'Mở Bệnh án',
              onTap: () => context.push('/clinician/medical-record/$id'),
            ),
            const SizedBox(width: 8),
            _actionBtn(
              icon: LucideIcons.edit2,
              color: AppColors.textSecondary,
              bgColor: Colors.transparent,
              bordered: true,
              tooltip: 'Chỉnh sửa',
              onTap: () {},
            ),
          ],
        )),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String tooltip,
    required VoidCallback onTap,
    bool bordered = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: bordered ? Border.all(color: AppColors.border) : null,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
