import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/sample.dart';
import 'package:go_router/go_router.dart';
import 'failure_reason_dialog.dart';

class SampleCard extends StatelessWidget {
  final Sample sample;
  final Function(SampleStatus) onStatusUpdate;
  /// Called when the specialist marks the sample as failed.
  /// Provides the human-readable failure reason to be saved as a note.
  final Function(String reason)? onFailure;

  const SampleCard({
    super.key,
    required this.sample,
    required this.onStatusUpdate,
    this.onFailure,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed('specialist-sample-detail',
            pathParameters: {'id': sample.testOrderId});
      },
      hoverColor: Colors.blue.shade50.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // ── Mã mẫu & Loại mẫu ───────────────────────────────────────
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    sample.id.length > 8
                        ? sample.id.substring(0, 8).toUpperCase()
                        : sample.id.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sample.sampleType,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            // ── Bệnh nhân ──────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Text(
                sample.patientName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF111827)),
              ),
            ),
            // ── Ngày thu nhận ──────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('dd/MM/yyyy').format(sample.collectedAt),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
            // ── Trạng thái ──────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Center(child: _StatusBadge(status: sample.status)),
            ),
            // ── Hành động ──────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Center(child: _buildActionCell(context)),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds dynamic, state-aware action buttons.
  /// Uses GestureDetector to absorb tap events and prevent row navigation.
  Widget _buildActionCell(BuildContext context) {
    switch (sample.status) {
      case SampleStatus.collected:
        return _AbsorbingWidget(
          child: ElevatedButton.icon(
            onPressed: () => _confirmStartCulturing(context),
            icon: const Icon(Icons.science_outlined, size: 16),
            label: const Text('Bắt đầu nuôi cấy',
                style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        );

      case SampleStatus.culturing:
        return _AbsorbingWidget(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _confirmHarvest(context),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label:
                    const Text('Thu hoạch', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () => _confirmFailure(context),
                icon: Icon(Icons.close_rounded,
                    size: 15, color: Colors.red.shade600),
                label: Text('Thất bại',
                    style: TextStyle(
                        fontSize: 12, color: Colors.red.shade600)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );

      case SampleStatus.harvested:
        return _AbsorbingWidget(
          child: ElevatedButton.icon(
            onPressed: () {
              context.goNamed(
                'specialist-analysis',
                pathParameters: {'orderId': sample.testOrderId},
              );
            },
            icon: const Icon(Icons.analytics_outlined, size: 16),
            label: const Text('Bắt đầu Phân tích',
                style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        );
      case SampleStatus.failed:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmStartCulturing(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.science_outlined, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Text('Bắt đầu nuôi cấy',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn bắt đầu nuôi cấy mẫu này?\nTrạng thái mẫu sẽ chuyển sang "Đang nuôi cấy".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Huỷ',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onStatusUpdate(SampleStatus.culturing);
    }
  }

  Future<void> _confirmFailure(BuildContext context) async {
    final reason = await showDialog<FailureReason>(
      context: context,
      builder: (ctx) => const FailureReasonDialog(),
    );

    if (reason != null) {
      onStatusUpdate(SampleStatus.failed);
      onFailure?.call(reason.label);
    }
  }

  Future<void> _confirmHarvest(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Text('Thu hoạch mẫu',
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn thu hoạch mẫu này?\nTrạng thái mẫu sẽ chuyển sang "Đã thu hoạch" và TestOrder sẽ chuyển sang "Đang phân tích".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Huỷ',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onStatusUpdate(SampleStatus.harvested);
    }
  }
}

/// Absorbs tap events so action buttons don't trigger the parent InkWell.
class _AbsorbingWidget extends StatelessWidget {
  final Widget child;
  const _AbsorbingWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // absorb
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SampleStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String text = '';
    Color color = Colors.grey;

    switch (status) {
      case SampleStatus.collected:
        text = 'MỚI';
        color = Colors.blue;
        break;
      case SampleStatus.culturing:
        text = 'NUÔI CẤY';
        color = Colors.orange;
        break;
      case SampleStatus.harvested:
        text = 'THÀNH CÔNG';
        color = Colors.green;
        break;
      case SampleStatus.failed:
        text = 'THẤT BẠI';
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
