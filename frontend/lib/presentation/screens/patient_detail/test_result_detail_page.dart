import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/shared/layouts/base_layout.dart';
import '../../widgets/shared/containers/app_card.dart';

class TestResultDetailPage extends StatelessWidget {
  final String id;

  const TestResultDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Bệnh án Điện tử',
      subtitle: 'Chi tiết kết quả xét nghiệm di truyền',
      showBackButton: true,
      headerActions: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.download, size: 18),
          label: const Text('Tải báo cáo PDF'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Patient Summary Bar
            _buildPatientSummary(),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Images
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildMetaphaseSection(),
                      const SizedBox(height: 24),
                      _buildKaryotypeSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column: Results & Conclusion
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildResultFormulaCard(),
                      const SizedBox(height: 24),
                      _buildConclusionCard(),
                      const SizedBox(height: 24),
                      _buildNotesCard(),
                      const SizedBox(height: 24),
                      _buildApprovalStatus(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BỆNH NHÂN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const Text('Johnathan Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildSummaryItem('NĂM SINH', '1982 (41t)'),
          _buildSummaryItem('MÃ SỐ XÉT NGHIỆM', id),
          _buildSummaryItem('NGÀY LẤY MẪU', '05/10/2023'),
          _buildSummaryItem('LOẠI MẪU', 'NST từ tế bào máu', isBadge: true),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
              child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            )
          else
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMetaphaseSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ảnh kỳ giữa (Metaphase Spread)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.zoomIn, size: 20)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 400,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/800x400'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaryotypeSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bộ nhiễm sắc thể (Karyotype)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                    child: const Text('G-BANDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: () {}, icon: const Icon(LucideIcons.maximize2, size: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(6, (index) => _buildChromosomePair(index + 1)),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Tổng cộng: 23 cặp nhiễm sắc thể đã được phân loại',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChromosomePair(int num) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Image.network('https://via.placeholder.com/60x80', height: 80),
          const SizedBox(height: 8),
          Text(num == 6 ? 'XY' : '$num', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultFormulaCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withAlpha(50)),
      ),
      child: Column(
        children: [
          const Text('KẾT QUẢ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          const SizedBox(height: 12),
          const Text(
            '46,XY',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nhiễm sắc thể đồ nam giới bình thường.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusionCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.checkCircle, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              const Text('Kết luận', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
            child: const Text(
              'Chưa phát hiện bất thường di truyền ở cấp độ Nhiễm sắc thể.',
              style: TextStyle(fontSize: 14, color: Color(0xFF065F46), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GHI CHÚ CHUYÊN MÔN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Text(
            'Quan sát 30 metaphases đều cho kết quả đồng nhất 46,XY. Các băng G rõ nét, không phát hiện mất đoạn, lặp đoạn hay chuyển đoạn lớn. Đề nghị kết hợp lâm sàng để đưa ra hướng điều trị tiếp theo.',
            style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NGƯỜI PHÊ DUYỆT', style: TextStyle(fontSize: 10, color: Colors.white70)),
                const Text('BS. Nguyễn Văn A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF065F46), borderRadius: BorderRadius.circular(16)),
            child: const Text('• ĐÃ PHÊ DUYỆT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
