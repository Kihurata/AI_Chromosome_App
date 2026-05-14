import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/chromosome.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../logic/bloc/clinician/test_result/test_result_detail_cubit.dart';
import '../../../../logic/bloc/clinician/test_result/test_result_detail_state.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../widgets/shared/layouts/base_layout.dart';
import '../../widgets/shared/containers/app_card.dart';

class TestResultDetailPage extends StatefulWidget {
  final String id;

  const TestResultDetailPage({super.key, required this.id});

  @override
  State<TestResultDetailPage> createState() => _TestResultDetailPageState();
}

class _TestResultDetailPageState extends State<TestResultDetailPage> {
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic()..readOnly = true;
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  void _onLoadSuccess(String? content) {
    if (content != null && content.isNotEmpty) {
      try {
        final delta = Document.fromJson(jsonDecode(content));
        _quillController.document = Document.fromDelta(delta.toDelta());
      } catch (e) {
        debugPrint('Error parsing report content: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TestResultDetailCubit, TestResultDetailState>(
      listener: (context, state) {
        if (state.status == WorkspaceStatus.success && state.testOrder != null) {
          _onLoadSuccess(state.testOrder!.reportContent);
        }
      },
      builder: (context, state) {
        if (state.status == WorkspaceStatus.loading) {
          return const BaseLayout(
            title: 'Bệnh án Điện tử',
            subtitle: 'Đang tải kết quả...',
            showBackButton: true,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == WorkspaceStatus.error) {
          return BaseLayout(
            title: 'Bệnh án Điện tử',
            subtitle: 'Lỗi tải dữ liệu',
            showBackButton: true,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.alertCircle, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${state.errorMessage}'),
                  const SizedBox(height: 16),
                  AppSecondaryButton(
                    text: 'Thử lại',
                    onPressed: () =>
                        context.read<TestResultDetailCubit>().loadData(widget.id),
                  ),
                ],
              ),
            ),
          );
        }

        final order = state.testOrder;
        if (order == null) {
          return const BaseLayout(
            title: 'Bệnh án Điện tử',
            subtitle: 'Không tìm thấy dữ liệu',
            showBackButton: true,
            child: Center(child: Text('Không tìm thấy thông tin xét nghiệm')),
          );
        }

        return BaseLayout(
          title: 'Bệnh án Điện tử',
          subtitle: 'Chi tiết kết quả xét nghiệm di truyền',
          showBackButton: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // ── Patient Summary Bar ──────────────────────────
                _buildPatientSummary(order),
                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left: Report + Karyotype ─────────────────
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _buildReportSection(),
                          const SizedBox(height: 24),
                          _buildKaryotypeSection(context, state.chromosomes),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // ── Right: Status info ───────────────────────
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildStatusCard(order),
                          const SizedBox(height: 24),
                          _buildApprovalStatus(order),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Patient Summary ────────────────────────────────────────────────────────

  Widget _buildPatientSummary(TestOrder order) {
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
            backgroundColor: AppColors.primaryBlue,
            child: Icon(LucideIcons.user, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BỆNH NHÂN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  order.patientName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildSummaryItem('MÃ BỆNH NHÂN', order.patientCode),
          _buildSummaryItem(
            'MÃ XÉT NGHIỆM',
            order.id
                .substring(0, order.id.length > 8 ? 8 : order.id.length)
                .toUpperCase(),
          ),
          _buildSummaryItem(
            'NGÀY TẠO',
            DateFormat('dd/MM/yyyy').format(order.createdAt),
          ),
          _buildSummaryItem(
            'TRẠNG THÁI',
            order.status.displayName,
            isBadge: true,
          ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          if (isBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            )
          else
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── Report Section (Quill read-only) ──────────────────────────────────────

  Widget _buildReportSection() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Báo cáo kết quả xét nghiệm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QuillEditor.basic(
              controller: _quillController,
              config: const QuillEditorConfig(
                autoFocus: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Karyotype Section with Tap-to-Zoom ───────────────────────────────────

  Widget _buildKaryotypeSection(BuildContext context, List<Chromosome> chromosomes) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bộ nhiễm sắc thể (Karyotype)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Nhấn vào từng cặp nhiễm sắc thể để xem chi tiết',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${chromosomes.length} nhiễm sắc thể',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          chromosomes.isEmpty
              ? _buildEmptyKaryotype()
              : _TappableKaryotypeGrid(
                  chromosomes: chromosomes,
                  onChromosomeTap: (c) => _showChromosomePreview(context, c),
                ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Hình ảnh trích xuất từ dữ liệu phân tích di truyền',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyKaryotype() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.microscope, size: 32, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text(
              'Chưa có dữ liệu nhiễm sắc thể',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showChromosomePreview(BuildContext context, Chromosome chromosome) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NST ${chromosome.label.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // Chromosome image
              Flexible(
                child: chromosome.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          chromosome.imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (ctx, err, st) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.broken_image, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Không thể tải hình ảnh',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(LucideIcons.imageOff, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text(
                            'Không có hình ảnh',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              // Info row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPreviewInfo('Nhãn', chromosome.label.toUpperCase()),
                    _buildPreviewInfo(
                      'Xoay',
                      '${chromosome.rotation.toStringAsFixed(1)}°',
                    ),
                    _buildPreviewInfo(
                      'Lật',
                      chromosome.isFlipped ? 'Có' : 'Không',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Status Card ─────────────────────────────────────────────────────────

  Widget _buildStatusCard(TestOrder order) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÔNG TIN CHUNG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ID Xét nghiệm:', order.id),
          _buildInfoRow(
            'Ngày chỉ định:',
            DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
          ),
          _buildInfoRow('Trạng thái:', order.status.displayName),
          if (order.specialistId != null)
            _buildInfoRow('Chuyên viên:', order.specialistId!),
          if (order.clinicianId != null)
            _buildInfoRow('Bác sĩ phụ trách:', order.clinicianId!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Approval Status ──────────────────────────────────────────────────────

  Widget _buildApprovalStatus(TestOrder order) {
    final isCompleted = order.status == TestOrderStatus.completed;
    final isRejected = order.status == TestOrderStatus.rejected;

    final bgColor = isCompleted
        ? const Color(0xFF111827)
        : isRejected
            ? const Color(0xFFFEF2F2)
            : Colors.grey.shade100;

    final iconColor = isCompleted
        ? Colors.white
        : isRejected
            ? Colors.red.shade400
            : Colors.grey;

    final labelColor = isCompleted
        ? Colors.white70
        : isRejected
            ? Colors.red.shade300
            : Colors.grey;

    final textColor = isCompleted
        ? Colors.white
        : isRejected
            ? Colors.red.shade700
            : Colors.grey.shade700;

    final statusText = isCompleted
        ? 'Hồ sơ đã được duyệt'
        : isRejected
            ? 'Hồ sơ bị từ chối'
            : 'Đang chờ phê duyệt';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? LucideIcons.shieldCheck : LucideIcons.shieldAlert,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRẠNG THÁI PHÊ DUYỆT',
                  style: TextStyle(fontSize: 10, color: labelColor),
                ),
                Text(
                  statusText,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '• ĐÃ PHÊ DUYỆT',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            )
          else if (isRejected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '• TỪ CHỐI',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tappable Karyotype Grid ───────────────────────────────────────────────────
//
// Wraps each chromosome cell with a GestureDetector so tapping triggers
// the onChromosomeTap callback. Keeps KaryotypeGrid unchanged.

class _TappableKaryotypeGrid extends StatelessWidget {
  final List<Chromosome> chromosomes;
  final void Function(Chromosome) onChromosomeTap;

  const _TappableKaryotypeGrid({
    required this.chromosomes,
    required this.onChromosomeTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group chromosomes by label (same logic as KaryotypeGrid)
    final Map<String, List<Chromosome>> grouped = {};
    for (final c in chromosomes) {
      final label = c.label.toUpperCase();
      grouped.putIfAbsent(label, () => []).add(c);
    }

    const rows = [
      ['1', '2', '3', '4', '5'],
      ['6', '7', '8', '9', '10', '11', '12'],
      ['13', '14', '15', '16', '17', '18'],
      ['19', '20', '21', '22', 'X', 'Y'],
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((label) {
                  final list = grouped[label] ?? [];
                  return _buildCell(label, list);
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCell(String label, List<Chromosome> list) {
    // Use the first chromosome of the group for tap callback
    final firstChromosome = list.isNotEmpty ? list.first : null;

    return GestureDetector(
      onTap: firstChromosome != null ? () => onChromosomeTap(firstChromosome) : null,
      child: MouseRegion(
        cursor: firstChromosome != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 60,
            maxWidth: 100,
            minHeight: 80,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: firstChromosome != null
                  ? AppColors.primaryBlue.withValues(alpha: 0.25)
                  : Colors.grey.shade100,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chromosome images
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: list.map((c) {
                    return c.imageUrl != null
                        ? Image.network(
                            c.imageUrl!,
                            width: 20,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, st) =>
                                const Icon(Icons.broken_image, size: 16, color: Colors.grey),
                          )
                        : Container(
                            width: 20,
                            height: 30,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.image, size: 12, color: Colors.grey),
                            ),
                          );
                  }).toList(),
                ),
              ),
              // Label row
              Container(
                width: double.infinity,
                color: firstChromosome != null
                    ? AppColors.primaryBlue.withValues(alpha: 0.06)
                    : Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: firstChromosome != null
                        ? AppColors.primaryBlue
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
