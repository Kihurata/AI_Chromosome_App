import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:medcore_crm/core/theme/app_colors.dart';
import 'package:medcore_crm/presentation/widgets/shared/form/app_text_field.dart';
import 'package:medcore_crm/presentation/widgets/shared/form/app_buttons.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final List<bool> _isExpanded = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch sử Khám bệnh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng cộng 24 lượt khám từ năm 2020',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            Row(
              children: [
            Row(
              children: [
                // Search Field
                SizedBox(
                  width: 240,
                  child: AppTextField(
                    hintText: 'Tìm kiếm hồ sơ...',
                    prefixIcon: LucideIcons.search,
                  ),
                ),
                const SizedBox(width: 12),
                // Filter Button
                AppSecondaryButton(
                  text: 'Lọc theo thời gian',
                  icon: LucideIcons.filter,
                  onPressed: () {},
                ),
              ],
            ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Timeline List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildTimelineItem(index);
          },
        ),
        
        // Load More Button
        const SizedBox(height: 24),
        Center(
          child: AppSecondaryButton(
            text: 'Tải thêm lịch sử',
            icon: LucideIcons.chevronDown,
            onPressed: () {},
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(int index) {
    final expanded = _isExpanded[index];
    
    // Mock data based on image
    final data = [
      {
        'date': '05/10/2023 - 09:45',
        'doctor': 'BS. Nguyễn Tri Phương',
        'type': 'NGOẠI TRÚ',
        'typeColor': AppColors.primaryBlue.withValues(alpha: 0.1),
        'typeTextColor': AppColors.primaryBlue,
        'diagnosis': 'VIÊM HỌNG CẤP (J02.9)',
        'icon': LucideIcons.briefcase,
        'iconColor': AppColors.primaryBlue,
      },
      {
        'date': '12/03/2023 - 14:30',
        'doctor': 'BS. Trần Thị Lan',
        'type': 'TÁI KHÁM',
        'typeColor': Colors.orange.withValues(alpha: 0.1),
        'typeTextColor': Colors.orange,
        'diagnosis': 'TĂNG HUYẾT ÁP ĐỘ 1 (I10)',
        'icon': LucideIcons.refreshCw,
        'iconColor': Colors.orange,
      },
      {
        'date': '15/11/2022 - 08:15',
        'doctor': 'BS. Lê Văn Hải',
        'type': 'CẤP CỨU',
        'typeColor': Colors.red.withValues(alpha: 0.1),
        'typeTextColor': Colors.red,
        'diagnosis': 'VIÊM PHỔI NẶNG (J18.0)',
        'icon': LucideIcons.asterisk,
        'iconColor': Colors.red,
      },
    ][index];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (data['iconColor'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(data['icon'] as IconData, size: 16, color: data['iconColor'] as Color),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['date'] as String,
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded[index] = !expanded;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  expanded ? 'Thu gọn' : 'Xem chi tiết',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  expanded ? LucideIcons.chevronUp : LucideIcons.chevronRight,
                                  size: 16,
                                  color: AppColors.primaryBlue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            data['doctor'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: data['typeColor'] as Color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              data['type'] as String,
                              style: TextStyle(
                                color: data['typeTextColor'] as Color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Chẩn đoán: ',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            TextSpan(
                              text: data['diagnosis'] as String,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (expanded) ...[
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 24),
                        
                        // Expanded Content Grid
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Reason & Vitals
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionLabel('LÝ DO ĐẾN KHÁM'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '“Đau họng kéo dài 3 ngày, có sốt nhẹ về chiều, nuốt vướng và mệt mỏi.”',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildSectionLabel('CHỈ SỐ SINH TỒN (VITALS)'),
                                  const SizedBox(height: 12),
                                  _buildVitalsGrid(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right Column: Symptoms & Paraclinical
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionLabel('TRIỆU CHỨNG & LÂM SÀNG'),
                                            const SizedBox(height: 8),
                                            _buildBulletPoint('Niêm mạc họng đỏ rực'),
                                            _buildBulletPoint('Amidan sưng nhẹ, không có giả mạc'),
                                            _buildBulletPoint('Hạch góc hàm sưng đau'),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionLabel('CẬN LÂM SÀNG'),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _buildBadge('Tổng phân tích máu'),
                                                const SizedBox(width: 8),
                                                _buildBadge('Nội soi TMH'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _buildSectionLabel('ĐƠN THUỐC'),
                                  const SizedBox(height: 12),
                                  _buildPrescriptionTable(),
                                  const SizedBox(height: 24),
                                  _buildSectionLabel('GHI CHÚ & LỜI DẶN'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Nghỉ ngơi, súc miệng nước muối sinh lý thường xuyên. Tái khám sau 7 ngày hoặc khi có dấu hiệu bất thường.',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildVitalItem('MẠCH', '82', 'bpm'),
        _buildVitalItem('HUYẾT ÁP', '120/80', 'mmHg'),
        _buildVitalItem('NHIỆT ĐỘ', '37.5', '°C'),
        _buildVitalItem('CÂN NẶNG', '70', 'kg'),
      ],
    );
  }

  Widget _buildVitalItem(String label, String value, String unit) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(3),
        },
        children: [
          // Table Header
          TableRow(
            children: [
              _buildTableCell('Tên thuốc', isHeader: true),
              _buildTableCell('SL', isHeader: true),
              _buildTableCell('Cách dùng', isHeader: true),
            ],
          ),
          // Table Rows
          TableRow(
            children: [
              _buildTableCell('Augmentin 1g'),
              _buildTableCell('14 viên'),
              _buildTableCell('Sáng 1, Chiều 1, sau ăn'),
            ],
          ),
          TableRow(
            children: [
              _buildTableCell('Paracetamol 500mg'),
              _buildTableCell('10 viên'),
              _buildTableCell('Uống khi sốt > 38.5°C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AppColors.textSecondary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
