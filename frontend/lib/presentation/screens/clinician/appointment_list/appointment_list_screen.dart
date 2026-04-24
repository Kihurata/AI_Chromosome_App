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
      subtitle: '',
      filterRow: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm tên, ID...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(LucideIcons.filter, size: 18, color: AppColors.primaryBlue),
          ),
        ],
      ),
      listContent: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 280),
            child: DataTable(
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
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
                _buildMockRow(context, 'LK-001', 'Nguyễn Văn A', 35, '08:30', 'Chưa khám', StatusType.warning),
                _buildMockRow(context, 'LK-002', 'Trần Thị B', 28, '09:15', 'Đang khám', StatusType.info),
                _buildMockRow(context, 'LK-003', 'Lê Văn D', 42, '10:00', 'Đã khám', StatusType.success),
                _buildMockRow(context, 'LK-004', 'Phạm Văn E', 31, '10:30', 'Chưa khám', StatusType.warning),
                _buildMockRow(context, 'LK-005', 'Hoàng Thị F', 26, '11:00', 'Đang khám', StatusType.info),
                _buildMockRow(context, 'LK-006', 'Ngô Văn G', 50, '13:30', 'Đã khám', StatusType.success),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildMockRow(
      BuildContext context, String id, String name, int age, String time, String statusText, StatusType statusType) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
        DataCell(Text(name)),
        DataCell(Text(age.toString(), style: const TextStyle(color: AppColors.textSecondary))),
        DataCell(Text(time)),
        DataCell(StatusBadge(status: statusType, label: statusText)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.activeBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.eye, size: 16),
                color: AppColors.primaryBlue,
                tooltip: 'Mở Bệnh án',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () {
                  context.push('/clinician/medical-record/$id');
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                icon: const Icon(LucideIcons.edit2, size: 16),
                color: AppColors.textSecondary,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () {},
              ),
            ),
          ],
        )),
      ],
    );
  }
}
