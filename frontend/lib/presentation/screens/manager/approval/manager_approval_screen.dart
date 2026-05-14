import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../../logic/bloc/manager/approval/manager_approval_cubit.dart';
import '../../../../logic/bloc/manager/approval/manager_approval_state.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../../widgets/shared/form/app_buttons.dart';
import '../../workspace/widgets/karyotype_grid.dart';
import '../../../../core/di/injection.dart';
import '../../../widgets/shared/layouts/base_layout.dart';

class ManagerApprovalScreen extends StatelessWidget {
  final String orderId;

  const ManagerApprovalScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ManagerApprovalCubit>()..loadOrderData(orderId),
      child: _ManagerApprovalView(orderId: orderId),
    );
  }
}

class _ManagerApprovalView extends StatefulWidget {
  final String orderId;

  const _ManagerApprovalView({required this.orderId});

  @override
  State<_ManagerApprovalView> createState() => _ManagerApprovalViewState();
}

class _ManagerApprovalViewState extends State<_ManagerApprovalView> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLoadSuccess(String? content) {
    if (content != null && content.isNotEmpty) {
      try {
        final delta = Document.fromJson(jsonDecode(content));
        _controller.document = Document.fromDelta(delta.toDelta());
      } catch (e) {
        debugPrint('Error parsing report content: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagerApprovalCubit, ManagerApprovalState>(
      listener: (context, state) {
        if (state.status == WorkspaceStatus.success && state.testOrder != null) {
          _onLoadSuccess(state.testOrder!.reportContent);
        } else if (state.status == WorkspaceStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.errorMessage}'), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return BaseLayout(
          title: 'Phê duyệt báo cáo',
          subtitle: 'Mã hồ sơ: #${widget.orderId}',
          showBackButton: true,
          child: state.status == WorkspaceStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Side: Editor & Actions
                      Expanded(
                        flex: 1,
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
                                'Kiểm tra & Chỉnh sửa báo cáo',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              
                              // Quill Editor
                              Expanded(
                                child: Container(
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
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: QuillEditor.basic(
                                            controller: _controller,
                                            config: const QuillEditorConfig(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: AppSecondaryButton(
                                      text: 'Từ chối',
                                      onPressed: () => _showRejectDialog(context),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppPrimaryButton(
                                      text: 'Duyệt Kết Quả',
                                      isLoading: state.status == WorkspaceStatus.loading,
                                      onPressed: () {
                                        final content = jsonEncode(_controller.document.toDelta().toJson());
                                        context.read<ManagerApprovalCubit>().approveOrder(widget.orderId, content);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      
                      // Right Side: Karyotype Preview
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
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
                                  'Dữ liệu đối soát',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'KARYOTYPE GRID',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                KaryotypeGrid(chromosomes: state.chromosomes),
                                const SizedBox(height: 24),
                                const Text(
                                  'THÔNG TIN BỆNH NHÂN',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                if (state.testOrder != null) ...[
                                  _buildInfoRow('Họ và tên:', state.testOrder!.patientName),
                                  _buildInfoRow('Mã BN:', state.testOrder!.patientCode),
                                  _buildInfoRow('Trạng thái:', state.testOrder!.status.displayName),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Từ chối báo cáo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vui lòng nhập lý do từ chối hồ sơ này:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Lý do từ chối...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ManagerApprovalCubit>().rejectOrder(widget.orderId, controller.text);
              Navigator.pop(dialogContext);
            },
            child: const Text('Xác nhận Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
