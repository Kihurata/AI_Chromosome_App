import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../domain/entities/sample.dart';
import '../../../../logic/bloc/specialist/ai_analysis_cubit.dart';
import '../../../../logic/bloc/specialist/ai_analysis_state.dart';
import '../../../../core/theme/app_colors.dart';

class BulkUploadDialog extends StatefulWidget {
  final Sample sample;

  const BulkUploadDialog({super.key, required this.sample});

  @override
  State<BulkUploadDialog> createState() => _BulkUploadDialogState();
}

class _BulkUploadDialogState extends State<BulkUploadDialog> {
  List<File> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiAnalysisCubit, AiAnalysisState>(
      listener: (context, state) {
        if (state is AiAnalysisWaitingForBackend) {
          Navigator.of(context).pop(); // Close dialog after upload starts
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang tải ảnh lên và bắt đầu phân tích AI...')),
          );
        } else if (state is AiAnalysisError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUploadArea(),
              const SizedBox(height: 24),
              if (_selectedFiles.isNotEmpty) _buildFileList(),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cloud_upload_outlined, color: Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tải ảnh Metaphase hàng loạt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Chọn nhiều ảnh để bắt đầu phân tích AI',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _pickFiles,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primaryBlue),
            SizedBox(height: 12),
            Text(
              'Bấm để chọn ảnh',
              style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
            ),
            Text(
              'Hỗ trợ JPG, PNG (tối đa 20 ảnh)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileList() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.image_outlined, size: 20),
            title: Text(
              _selectedFiles[index].path.split('/').last,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => setState(() => _selectedFiles.removeAt(index)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Bỏ qua', style: TextStyle(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _selectedFiles.isEmpty
              ? null
              : () {
                  context.read<AiAnalysisCubit>().uploadMultipleImages(
                        _selectedFiles,
                        widget.sample.testOrderId,
                      );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Tải lên và Phân tích'),
        ),
      ],
    );
  }
}
