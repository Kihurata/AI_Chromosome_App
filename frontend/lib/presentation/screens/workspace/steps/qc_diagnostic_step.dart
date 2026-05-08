import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../../../domain/entities/metaphase_image.dart';
import '../../../widgets/shared/form/app_text_field.dart';


class QcDiagnosticStep extends StatefulWidget {
  const QcDiagnosticStep({super.key});

  @override
  State<QcDiagnosticStep> createState() => _QcDiagnosticStepState();
}

class _QcDiagnosticStepState extends State<QcDiagnosticStep> {
  final TextEditingController _iscnController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    _iscnController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: ISCN and Remarks
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bước 4: Phê duyệt QC & Chẩn đoán',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Công thức Karyotype (ISCN)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _iscnController,
                    hintText: 'Ví dụ: 46,XX hoặc 47,XY,+21',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nhận xét chẩn đoán',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _remarksController,
                    maxLines: 5,
                    hintText: 'Nhập ghi chú chẩn đoán, các bất thường nếu có...',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right side: AI Suggestions
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'AI Gợi ý Chẩn đoán',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      if (state.suggestions.isEmpty)
                        const Center(
                          child: Text(
                            'Chưa có gợi ý. Hãy lưu kết quả ở bước 3 trước.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ...state.suggestions.map((DiagnosisSuggestion suggestion) => Column(
                            children: [
                              _buildSuggestionCard(
                                suggestion.iscn,
                                suggestion.description,
                                suggestion.confidence,
                              ),
                              const SizedBox(height: 12),
                            ],
                          )),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String iscn, String description, double confidence) {
    return InkWell(
      onTap: () {
        _iscnController.text = iscn;
        _remarksController.text = description;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  iscn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(confidence * 100).toInt()}%',
                    style: TextStyle(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
