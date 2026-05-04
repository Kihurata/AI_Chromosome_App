import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../core/theme/app_colors.dart';

class SampleCard extends StatelessWidget {
  final Sample sample;
  final Function(SampleStatus) onStatusUpdate;

  const SampleCard({
    super.key,
    required this.sample,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLeading(),
          const SizedBox(width: 20),
          Expanded(child: _buildInfo()),
          const SizedBox(width: 20),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getStatusIcon(), color: _getStatusColor(), size: 30),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              sample.id.substring(0, 8).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: sample.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Bệnh nhân: ${sample.patientName}',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Loại mẫu: ${sample.sampleType} | Thu nhận: ${DateFormat('dd/MM/yyyy').format(sample.collectedAt)}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.info_outline, color: AppColors.primaryBlue),
          tooltip: 'Xem Test Order',
          onPressed: () {
            // Logic điều hướng đến Test Order
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chuyển hướng đến chi tiết Test Order...')),
            );
          },
        ),
        const SizedBox(width: 8),
        _buildPopupMenu(),
      ],
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<SampleStatus>(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      onSelected: onStatusUpdate,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: SampleStatus.culturing,
          child: Text('Bắt đầu nuôi cấy'),
        ),
        const PopupMenuItem(
          value: SampleStatus.harvested,
          child: Text('Thu hoạch thành công'),
        ),
        const PopupMenuItem(
          value: SampleStatus.failed,
          child: Text('Đánh dấu thất bại'),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (sample.status) {
      case SampleStatus.collected:
        return Colors.blue;
      case SampleStatus.culturing:
        return Colors.orange;
      case SampleStatus.harvested:
        return Colors.green;
      case SampleStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (sample.status) {
      case SampleStatus.collected:
        return Icons.biotech_outlined;
      case SampleStatus.culturing:
        return Icons.hourglass_empty;
      case SampleStatus.harvested:
        return Icons.check_circle_outline;
      case SampleStatus.failed:
        return Icons.error_outline;
    }
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
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
