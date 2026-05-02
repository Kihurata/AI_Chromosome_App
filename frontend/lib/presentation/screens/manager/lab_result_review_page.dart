import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../logic/bloc/manager/manager_approval_cubit.dart';
import '../../../../logic/bloc/manager/manager_approval_state.dart';
import '../../widgets/shared/layouts/base_layout.dart';
import '../../widgets/shared/containers/app_card.dart';
import '../../widgets/shared/form/app_text_field.dart';

class LabResultReviewPage extends StatefulWidget {
  final String orderId;

  const LabResultReviewPage({super.key, required this.orderId});

  @override
  State<LabResultReviewPage> createState() => _LabResultReviewPageState();
}

class _LabResultReviewPageState extends State<LabResultReviewPage> {
  final TextEditingController noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Hệ thống Bệnh viện',
      subtitle: 'Duyệt kết quả xét nghiệm di truyền',
      showBackButton: true,
      child: BlocListener<ManagerApprovalCubit, ManagerApprovalState>(
        listener: (context, state) {
          if (state is ManagerApprovalSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.successText),
            );
            context.pop();
          } else if (state is ManagerApprovalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerText),
            );
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column: Details & Decision
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResultInfoSection(),
                    const SizedBox(height: 24),
                    _buildDecisionSection(),
                  ],
                ),
              ),
            ),
            
            // Right Column: PDF Preview
            Expanded(
              flex: 4,
              child: Container(
                color: const Color(0xFFF3F4F6),
                padding: const EdgeInsets.all(32),
                child: _buildPdfPreview(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultInfoSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.fileText, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    'THÔNG TIN CẦN DUYỆT',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Mã xét nghiệm: CYTO-2023-0922',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Center(
            child: Column(
              children: [
                const Text(
                  'CÔNG THỨC ISCN',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 8),
                const Text(
                  '47 , XY , +21',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Trisomy 21 (Hội chứng Down)',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.primaryBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text('KẾT LUẬN CHẨN ĐOÁN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Nghi ngờ Hội chứng Down', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),

          const Text('DIỄN GIẢI & TƯ VẤN DI TRUYỀN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text(
            'Kết quả phân tích nhiễm sắc thể đồ (Karyotype) từ tế bào máu ngoại vi cho thấy có 47 nhiễm sắc thể, bao gồm sự xuất hiện của 3 nhiễm sắc thể số 21 (Trisomy 21). Công thức này khẳng định bệnh nhân mắc Hội chứng Down thể thuần. Đề nghị tư vấn di truyền cho gia đình về nguy cơ tái mắc và thực hiện các xét nghiệm sàng lọc trước sinh cho những lần mang thai sau.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _buildMetaItem(LucideIcons.layoutGrid, 'SỐ LƯỢNG METAPHASE', '30/30'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetaItem(LucideIcons.microscope, 'PHƯƠNG PHÁP', 'G-Banding Karyotyping'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mock Images
          Row(
            children: [
              _buildImageThumbnail('https://via.placeholder.com/150'),
              const SizedBox(width: 12),
              _buildImageThumbnail('https://via.placeholder.com/150'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(String url) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        border: Border.all(color: AppColors.border),
      ),
    );
  }

  Widget _buildDecisionSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('QUYẾT ĐỊNH PHÊ DUYỆT', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '• Chờ duyệt',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('GHI CHÚ CỦA MANAGER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          AppTextField(
            labelText: 'Ghi chú phê duyệt',
            controller: noteController,
            hintText: 'Nhập ghi chú hoặc yêu cầu chỉnh sửa tại đây...',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<ManagerApprovalCubit>().reject(widget.orderId),
                  icon: const Icon(LucideIcons.edit3, size: 18),
                  label: const Text('Yêu cầu chỉnh sửa'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    foregroundColor: const Color(0xFFEA580C),
                    side: const BorderSide(color: Color(0xFFEA580C)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.read<ManagerApprovalCubit>().approve(widget.orderId),
                  icon: const Icon(LucideIcons.checkCircle, size: 18),
                  label: const Text('Phê duyệt & Ký số'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(LucideIcons.eye, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'XEM TRƯỚC BÁO CÁO (A4)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.search, size: 20)),
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.printer, size: 20)),
            IconButton(onPressed: () {}, icon: const Icon(LucideIcons.download, size: 20)),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  // Mock PDF Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            color: AppColors.primaryBlue,
                            child: const Icon(LucideIcons.microscope, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CLINICAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('COBALT LAB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('MEDICAL GENETICS CENTER', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Số phiếu: CYTO/2023/10294', style: TextStyle(fontSize: 8)),
                          Text('Ngày in: 24/10/2023', style: TextStyle(fontSize: 8)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 48, thickness: 2),
                  
                  const Text(
                    'PHIẾU KẾT QUẢ\nXÉT NGHIỆM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 48),

                  // Mock Patient Info
                  Table(
                    children: [
                      _buildPdfTableRow('Họ và tên:', 'JOHNATHAN DOE', 'Ngày sinh:', '15/05/2020'),
                      _buildPdfTableRow('Giới tính:', 'Nam', 'Mã BN:', '#88291-ZX'),
                    ],
                  ),
                  const SizedBox(height: 48),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: const Color(0xFFF9FAFB),
                    child: Column(
                      children: [
                        const Text('CÔNG THỨC ISCN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('47 , XY , +21', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KẾT LUẬN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 8),
                        Text('Hội chứng Down (Trisomy 21).', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 32),
                        Text('GHI CHÚ & TƯ VẤN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 8),
                        Text(
                          'Mẫu phân tích hiển thị thừa một nhiễm sắc thể số 21 trong tất cả các tế bào quan sát được (30/30 metaphases). Kết quả này phù hợp với các biểu hiện lâm sàng của Hội chứng Down. Gia đình nên tham gia tư vấn di truyền chuyên sâu để nhận thêm thông tin hỗ trợ và lập kế hoạch chăm sóc trẻ.',
                          style: TextStyle(fontSize: 10, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildPdfTableRow(String label1, String value1, String label2, String value2) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label1, style: const TextStyle(fontSize: 10)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(value1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label2, style: const TextStyle(fontSize: 10)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(value2, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
