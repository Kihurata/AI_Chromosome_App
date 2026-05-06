import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../domain/entities/metaphase_image.dart';
import '../../../../domain/repositories/workspace_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../logic/bloc/specialist/ai_analysis_cubit.dart';
import '../../../../logic/bloc/specialist/ai_analysis_state.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';

class ScreeningStep extends StatefulWidget {
  final String orderId;
  const ScreeningStep({super.key, required this.orderId});

  @override
  State<ScreeningStep> createState() => _ScreeningStepState();
}

class _ScreeningStepState extends State<ScreeningStep> {
  Future<void> _pickAndUploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      final bytesList = result.files
          .where((f) => f.bytes != null)
          .map((f) => f.bytes!)
          .toList();

      if (bytesList.isNotEmpty && mounted) {
        context.read<AiAnalysisCubit>().uploadMultipleImages(
              bytesList,
              widget.orderId,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bước 1: Sàng lọc ảnh Metaphase',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn 1-3 ảnh rõ nét nhất để tiến hành bóc tách. Upload ảnh mới nếu cần.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          // Upload button row
          BlocConsumer<AiAnalysisCubit, AiAnalysisState>(
            listener: (context, state) {
              if (state is AiAnalysisUploadCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tải ảnh lên thành công! Bấm Phân tích AI để tiếp tục.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is AiAnalysisError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isUploading = state is AiAnalysisUploadingProgress;
              final current = isUploading ? state.current : 0;
              final total = isUploading ? state.total : 0;

              return Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : _pickAndUploadFiles,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      isUploading ? 'Đang tải lên $current/$total...' : 'Upload ảnh',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Image grid
          Expanded(
            child: StreamBuilder(
              stream: getIt<WorkspaceRepository>().watchMetaphaseImages(widget.orderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Chưa có ảnh nào được tải lên.'));
                }

                return snapshot.data!.fold(
                  (failure) => Center(child: Text('Lỗi tải ảnh: ${failure.message}')),
                  (images) {
                    if (images.isEmpty) {
                      return const Center(child: Text('Chưa có ảnh nào được tải lên.'));
                    }

                    final hasUploadedImages = images.any(
                      (img) => img.status == AiProcessingStatus.uploaded,
                    );
                    final isProcessingAny = images.any(
                      (img) => img.status == AiProcessingStatus.processing,
                    );

                    return Column(
                      children: [
                        // AI trigger button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: (hasUploadedImages && !isProcessingAny)
                                  ? () => context.read<AiAnalysisCubit>().triggerAnalysis(widget.orderId)
                                  : null,
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Phân tích AI'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Image grid
                        Expanded(
                          child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                            builder: (context, workspaceState) {
                              final selectedIds = workspaceState.selectedImageIds;

                              return GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 250,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  final image = images[index];
                                  final imageId = image.id;
                                  final isSelected = selectedIds.contains(imageId);
                                  final isMaxSelected = selectedIds.length >= 3;
                                  final isDisabled = isMaxSelected && !isSelected;
                                  const aiScore = 95; // Mock until backend returns score

                                  return GestureDetector(
                                    onTap: isDisabled
                                        ? null
                                        : () => context.read<WorkspaceCubit>().toggleImageSelection(imageId),
                                    child: Opacity(
                                      opacity: isDisabled ? 0.5 : 1.0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              // Use Image.network (uses HTML img on web, bypasses CORS)
                                              Image.network(
                                                image.rawImageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Center(
                                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                                ),
                                              ),
                                              // Processing overlay
                                              if (image.status == AiProcessingStatus.processing)
                                                Container(
                                                  color: Colors.black.withValues(alpha: 0.4),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                ),
                                              // Completed AI score badge
                                              if (image.status == AiProcessingStatus.completed)
                                                Positioned(
                                                  top: 8,
                                                  left: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: aiScore >= 90
                                                          ? Colors.green
                                                          : (aiScore >= 80 ? Colors.orange : Colors.red),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'AI: $aiScore',
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              // Selection checkmark
                                              if (isSelected)
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color: Theme.of(context).primaryColor,
                                                      size: 28,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
