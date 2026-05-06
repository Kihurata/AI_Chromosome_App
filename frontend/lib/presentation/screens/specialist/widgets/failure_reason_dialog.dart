import 'package:flutter/material.dart';

enum FailureReason {
  contaminated,
  insufficientCells,
  technicalError,
  other;

  String get label {
    switch (this) {
      case FailureReason.contaminated:
        return 'Mẫu bị nhiễm khuẩn';
      case FailureReason.insufficientCells:
        return 'Không đủ tế bào phân chia';
      case FailureReason.technicalError:
        return 'Lỗi kỹ thuật trong quá trình xử lý';
      case FailureReason.other:
        return 'Lý do khác';
    }
  }
}

class FailureReasonDialog extends StatefulWidget {
  const FailureReasonDialog({super.key});

  @override
  State<FailureReasonDialog> createState() => _FailureReasonDialogState();
}

class _FailureReasonDialogState extends State<FailureReasonDialog> {
  FailureReason? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Xác nhận Thất bại',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vui lòng chọn lý do thất bại của mẫu nuôi cấy. Thao tác này không thể hoàn tác.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ...FailureReason.values.map((reason) => _buildReasonOption(reason)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Huỷ', style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(_selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Xác nhận Thất bại'),
        ),
      ],
    );
  }

  Widget _buildReasonOption(FailureReason reason) {
    final isSelected = _selected == reason;
    return GestureDetector(
      onTap: () => setState(() => _selected = reason),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.red.shade400 : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.red.shade600 : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              reason.label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.red.shade700 : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
