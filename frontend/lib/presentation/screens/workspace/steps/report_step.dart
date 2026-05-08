import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../../widgets/shared/form/app_buttons.dart';
import '../widgets/karyotype_grid.dart';

class ReportStep extends StatefulWidget {
  const ReportStep({super.key});

  @override
  State<ReportStep> createState() => _ReportStepState();
}

class _ReportStepState extends State<ReportStep> {
  late QuillController _controller;
  QuillController? _previewController;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: BlocConsumer<WorkspaceCubit, WorkspaceState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == WorkspaceStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã gửi báo cáo thành công!'), backgroundColor: Colors.green),
            );
            context.goNamed('specialist-dashboard');
          } else if (state.status == WorkspaceStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Editor
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Soạn thảo báo cáo',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'MÃ BN: #88291-ZX', // Mock or bind to state
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        
                        // Images Section
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildImageCard('Karyotype', 'https://via.placeholder.com/100'),
                            _buildImageCard('Metaphase', 'https://via.placeholder.com/100'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // ISCN Section
                        const Text(
                          'CÔNG THỨC ISCN',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '47,XY,+21', // Mock or bind to state
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 24),
                        
                        // Editor
                        const Text(
                          'Diễn giải & Tư vấn Di truyền',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        
                        // Quill Editor without Provider
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              QuillSimpleToolbar(
                                controller: _controller,
                                config: const QuillSimpleToolbarConfig(),
                              ),
                              const Divider(height: 1),
                              Container(
                                height: 200,
                                padding: const EdgeInsets.all(8),
                                child: QuillEditor.basic(
                                  controller: _controller,
                                  config: const QuillEditorConfig(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            AppSecondaryButton(
                              text: 'Cập nhật xem trước',
                              onPressed: () {
                                setState(() {
                                  _showPreview = true;
                                  _previewController?.dispose();
                                  _previewController = QuillController(
                                    document: Document.fromDelta(_controller.document.toDelta()),
                                    selection: const TextSelection.collapsed(offset: 0),
                                  );
                                  _previewController!.readOnly = true;
                                });
                              },
                            ),
                            AppPrimaryButton(
                              text: 'Hoàn tất & Gửi Phê duyệt',
                              isLoading: state.status == WorkspaceStatus.loading,
                              onPressed: state.status == WorkspaceStatus.loading
                                  ? null
                                  : () {
                                      final deltaJson = jsonEncode(_controller.document.toDelta().toJson());
                                      context.read<WorkspaceCubit>().submitAnalysis(deltaJson);
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              
              // Right Side: Preview
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _showPreview && _previewController != null
                      ? _buildPreviewArea(state)
                      : const Center(
                          child: Text(
                            'Bấm "Cập nhật xem trước" để xem kết quả',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCard(String label, String url) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.network(url, fit: BoxFit.cover),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            color: Colors.grey.shade100,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea(WorkspaceState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'XEM TRƯỚC (A4)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          // Simulated A4 Page
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'PHIẾU KẾT QUẢ XÉT NGHIỆM DI TRUYỀN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Mã xét nghiệm: KAI-2024-88291'),
                const Text('Họ và tên: Johnathan Doe'),
                const Text('Ngày sinh: 12/08/1992'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'KẾT QUẢ PHÂN TÍCH (ISCN 2020)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    '47,XY,+21',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'HÌNH ẢNH KARYOTYPE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                KaryotypeGrid(chromosomes: state.chromosomes),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả chi tiết:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Render Quill Content as Read-only
                QuillEditor.basic(
                  controller: _previewController!,
                  config: const QuillEditorConfig(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
