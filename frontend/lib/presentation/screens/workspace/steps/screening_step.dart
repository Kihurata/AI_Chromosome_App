import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';

class ScreeningStep extends StatefulWidget {
  final String orderId;
  const ScreeningStep({super.key, required this.orderId});

  @override
  State<ScreeningStep> createState() => _ScreeningStepState();
}

class _ScreeningStepState extends State<ScreeningStep> {
  // Temporary mock data for UI visualization
  final List<Map<String, dynamic>> _mockImages = List.generate(8, (index) => {
    'id': 'img_$index',
    'url': 'https://picsum.photos/seed/$index/300/300',
    'ai_score': 70 + (index * 5) % 30, // Mock score between 70-100
  });

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
            'Chọn 1-3 ảnh rõ nét nhất (đã được AI đánh giá sơ bộ) để tiến hành bóc tách.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
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
                  itemCount: _mockImages.length,
                  itemBuilder: (context, index) {
                    final image = _mockImages[index];
                    final imageId = image['id'] as String;
                    final aiScore = image['ai_score'] as int;
                    final isSelected = selectedIds.contains(imageId);
                    
                    // AC-6: Disable unselected if 3 are already selected
                    final isMaxSelected = selectedIds.length >= 3;
                    final isDisabled = isMaxSelected && !isSelected;

                    return GestureDetector(
                      onTap: isDisabled ? null : () {
                        context.read<WorkspaceCubit>().toggleImageSelection(imageId);
                      },
                      child: Opacity(
                        opacity: isDisabled ? 0.5 : 1.0,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(image['url'] as String),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Top Left: AI Score Badge
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: aiScore >= 90 ? Colors.green : (aiScore >= 80 ? Colors.orange : Colors.red),
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
                              // Top Right: Check Icon
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
