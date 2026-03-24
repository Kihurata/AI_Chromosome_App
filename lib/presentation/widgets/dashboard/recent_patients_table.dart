import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../shared/status_badge.dart';

class RecentPatientsTable extends StatelessWidget {
  const RecentPatientsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header Title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hoạt động bệnh nhân gần đây\nXem lại các cập nhật thời gian thực về quy trình y tế',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Xem tất cả báo cáo', style: TextStyle(color: AppColors.primaryBlue)),
                )
              ],
            ),
          ),
          
          // Table Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('TÊN BỆNH NHÂN', style: _headerStyle)),
                Expanded(flex: 3, child: Text('HÀNH ĐỘNG', style: _headerStyle)),
                Expanded(flex: 2, child: Text('TRẠNG THÁI', style: _headerStyle)),
                Expanded(flex: 2, child: Text('THỜI GIAN', style: _headerStyle)),
                SizedBox(width: 32),
              ],
            ),
          ),
          
          // Table Data Rows
          _buildRow('Johnathan Doe', 'Xét nghiệm máu', BadgeType.processing, 'Đang xử lý', '10:30 AM', 'JD', Colors.blue[100]!, Colors.blue[900]!),
          _buildRow('Jane Smith', 'Phân tích AI', BadgeType.success, 'Hoàn thành', '09:15 AM', 'JS', Colors.purple[100]!, Colors.purple[900]!),
          _buildRow('Robert Brown', 'Xem lại kết quả khẩn cấp', BadgeType.danger, 'Khẩn cấp', '08:45 AM', 'RB', Colors.red[100]!, Colors.red[900]!),
          _buildRow('Emily Davis', 'Chụp cộng hưởng từ (MRI)', BadgeType.processing, 'Đang xử lý', '08:00 AM', 'ED', Colors.yellow[100]!, Colors.yellow[900]!),
          _buildRow('Michael Wilson', 'Phân tích X-Quang', BadgeType.success, 'Hoàn thành', 'Hôm qua', 'MW', Colors.grey[200]!, Colors.grey[800]!, isLast: true),

          // Pagination Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Đang hiển thị 5 trên 128 cập nhật', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Row(
                  children: [
                    OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border)), child: const Text('Trước', style: TextStyle(color: AppColors.textSecondary))),
                    const SizedBox(width: 8),
                    Container(
                      width: 40, height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
                      child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40, height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                      child: const Text('2', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: (){}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border)), child: const Text('Tiếp theo', style: TextStyle(color: AppColors.textSecondary))),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  Widget _buildRow(String name, String action, BadgeType type, String statusText, String time, String initials, Color avatarBg, Color avatarText, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: avatarBg,
                  child: Text(initials, style: TextStyle(color: avatarText, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                // Add tiny indicator if available
                if (name == 'Johnathan Doe') ...[
                   const SizedBox(width: 8),
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                     child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                   )
                ]
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(LucideIcons.activity, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(action, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(text: statusText, type: type),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(time, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(LucideIcons.moreVertical, size: 20, color: AppColors.textPlaceholder),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
