import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/shared/data_display/app_data_table.dart';
import '../../../../widgets/shared/data_display/status_badge.dart';

class TestResultsTab extends StatelessWidget {
  const TestResultsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Title & Filters
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kết quả Xét nghiệm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Row(
              children: [
                _buildFilterButton(LucideIcons.flaskConical, 'Tất cả loại xét nghiệm'),
                const SizedBox(width: 12),
                _buildFilterButton(LucideIcons.calendar, '6 tháng gần nhất'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Table
        Expanded(
          child: AppDataTable(
            searchHint: 'Tìm kiếm xét nghiệm...',
            countText: '4 xét nghiệm',
            headerRow: const _HeaderRow(),
            rows: [
              _buildResultRow(
                context,
                id: '#XN-88210',
                name: 'Phân tích NST (Karyotyping)',
                date: '05/10/2023',
                dept: 'Di truyền',
                status: 'Hoàn thành',
                badgeType: BadgeType.success,
              ),
              _buildResultRow(
                context,
                id: '#XN-88209',
                name: 'Công thức máu toàn bộ',
                date: '12/03/2023',
                dept: 'Huyết học',
                status: 'Hoàn thành',
                badgeType: BadgeType.success,
              ),
              _buildResultRow(
                context,
                id: '#XN-88195',
                name: 'Sinh hóa máu (Glucose)',
                date: '15/11/2022',
                dept: 'Sinh hóa',
                status: 'Hoàn thành',
                badgeType: BadgeType.success,
              ),
              _buildResultRow(
                context,
                id: '#XN-88215',
                name: 'Chức năng Gan (AST/ALT)',
                date: 'Hôm nay',
                dept: 'Sinh hóa',
                status: 'Đang xử lý',
                badgeType: BadgeType.processing,
                isProcessing: true,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Bottom Alert Cards
        Row(
          children: [
            Expanded(
              child: _buildAlertCard(
                icon: LucideIcons.alertTriangle,
                iconColor: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEF2F2),
                title: 'Chỉ số bất thường cần chú ý',
                content: 'Kết quả xét nghiệm máu (12/03/2023) cho thấy mức Cholesterol LDL vượt ngưỡng tham chiếu.',
                actionText: 'Xem chi tiết',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildAlertCard(
                icon: LucideIcons.microscope,
                iconColor: AppColors.primaryBlue,
                bgColor: const Color(0xFFEFF6FF),
                title: 'Xét nghiệm mới nhất',
                content: 'Karyotyping hoàn thành vào 05/10/2023. Không phát hiện bất thường cấu trúc nhiễm sắc thể.',
                actionText: 'Tải báo cáo tóm tắt',
                isDownload: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context, {
    required String id,
    required String name,
    required String date,
    required String dept,
    required String status,
    required BadgeType badgeType,
    bool isProcessing = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(id, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(
            flex: 4,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 14),
            ),
          ),
          Expanded(flex: 3, child: Text(date, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
          Expanded(flex: 3, child: Text(dept, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(text: status, type: badgeType),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isProcessing) ...[
                  IconButton(
                    onPressed: () => context.push('/clinician/test-result/$id'),
                    icon: const Icon(LucideIcons.eye, size: 18, color: AppColors.textSecondary),
                    tooltip: 'Xem chi tiết',
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.download, size: 18, color: AppColors.textSecondary),
                    tooltip: 'Tải PDF',
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(LucideIcons.hourglass, size: 18, color: AppColors.textPlaceholder),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String content,
    required String actionText,
    bool isDownload = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        actionText,
                        style: TextStyle(
                          color: isDownload ? AppColors.primaryBlue : const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isDownload ? LucideIcons.download : LucideIcons.arrowRight,
                        size: 14,
                        color: isDownload ? AppColors.primaryBlue : const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary);
    return const Row(
      children: [
        Expanded(flex: 2, child: Text('ID XÉT NGHIỆM', style: style)),
        Expanded(flex: 4, child: Text('TÊN XÉT NGHIỆM', style: style)),
        Expanded(flex: 3, child: Text('NGÀY THỰC HIỆN', style: style)),
        Expanded(flex: 3, child: Text('CHUYÊN KHOA', style: style)),
        Expanded(flex: 2, child: Text('TRẠNG THÁI', style: style)),
        SizedBox(width: 80, child: Text('THAO TÁC', style: style, textAlign: TextAlign.center)),
      ],
    );
  }
}
