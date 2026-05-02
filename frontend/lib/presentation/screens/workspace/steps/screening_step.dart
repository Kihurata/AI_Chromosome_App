import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../../../logic/bloc/specialist/ai_analysis_cubit.dart';
import '../../../../logic/bloc/specialist/ai_analysis_state.dart';

class ScreeningStep extends StatefulWidget {
  final String orderId;
  const ScreeningStep({super.key, required this.orderId});

  @override
  State<ScreeningStep> createState() => _ScreeningStepState();
}

class _ScreeningStepState extends State<ScreeningStep> {
  final List<int> _selectedIndices = [];

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
            'Chọn các ảnh rõ nét nhất (đã được AI đánh giá sơ bộ) để tiến hành bóc tách.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: 8, // Placeholder count
              itemBuilder: (context, index) {
                final isSelected = _selectedIndices.contains(index);
                final imageId = index.toString(); // Placeholder ID
                
                return BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                  builder: (context, state) {
                    final isThisImageAnalyzing = (state is AiAnalysisWaitingForBackend || state is AiAnalysisUploading) && 
                        context.read<AiAnalysisCubit>().analyzingImageId == imageId;

                    return GestureDetector(
                      onTap: isThisImageAnalyzing ? null : () {
                        setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      },
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                            width: 3,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage('https://via.placeholder.com/300'), // Placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
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
                            if (isThisImageAnalyzing)
                              Container(
                                color: Colors.black45,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(color: Colors.white),
                                      SizedBox(height: 8),
                                      Text(
                                        'AI Analyzing...',
                                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          BlocConsumer<AiAnalysisCubit, AiAnalysisState>(
            listener: (context, state) {
              if (state is AiAnalysisError) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Phân tích AI thất bại'),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Thử lại'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // D3: Fallback to Step 2 (Manual Slicing)
                          context.read<WorkspaceCubit>().goToStep(2);
                        },
                        child: const Text('Tự cắt thủ công'),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, state) {
              final isAnalyzing = state is AiAnalysisWaitingForBackend || state is AiAnalysisUploading;
              
              return Center(
                child: ElevatedButton.icon(
                  onPressed: isAnalyzing || _selectedIndices.isEmpty
                      ? null 
                      : () => context.read<AiAnalysisCubit>().triggerAnalysis(
                            widget.orderId, 
                            _selectedIndices.first.toString(),
                          ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: isAnalyzing 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isAnalyzing ? 'Đang phân tích...' : 'Bắt đầu phân tích AI',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
