import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../../../domain/entities/chromosome.dart';

class SlicingStep extends StatefulWidget {
  const SlicingStep({super.key});

  @override
  State<SlicingStep> createState() => _SlicingStepState();
}

class _SlicingStepState extends State<SlicingStep> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceCubit, WorkspaceState>(
      builder: (context, state) {
        final chromosomes = state.chromosomes;
        
        // Split chromosomes into unassigned (pool) and assigned (grid)
        final unassigned = chromosomes.where((c) => c.label == 'unassigned' || c.label == 'unknown').toList();
        
        // Simple map for the grid
        final Map<String, List<Chromosome>> gridData = {
          for (var i = 1; i <= 22; i++) i.toString(): [],
          'X': [],
          'Y': [],
        };
        
        for (var c in chromosomes) {
          if (gridData.containsKey(c.label)) {
            gridData[c.label]!.add(c);
          }
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bước 2: Phân loại - Tách NST (Bản thực tế)',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Kéo thả để phân loại. Bước này hiện có thể bỏ qua để sang Bước 3.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.read<WorkspaceCubit>().nextStep(),
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Bỏ qua & Sang Bước 3'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => context.read<WorkspaceCubit>().nextStep(),
                        icon: const Icon(Icons.check),
                        label: const Text('Hoàn thành'),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel: Unclassified Pool
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NST chưa phân loại (${unassigned.length})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider(),
                            Expanded(
                              child: unassigned.isEmpty 
                                ? const Center(child: Text('Đã phân loại hết'))
                                : GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: unassigned.length,
                                    itemBuilder: (context, index) {
                                      return _buildChromosomeCard(unassigned[index]);
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Panel: Karyotype Grid
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lưới Phân loại',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider(),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: gridData.keys.length,
                                itemBuilder: (context, index) {
                                  final key = gridData.keys.elementAt(index);
                                  final items = gridData[key]!;
                                  return _buildGridCell(key, items);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChromosomeCard(Chromosome chromosome) {
    final hasImage = chromosome.imageUrl != null && chromosome.imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: hasImage
              ? Image.network(
                  chromosome.imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                )
              : const Icon(Icons.line_weight, color: Colors.blue),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Text(
              chromosome.label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCell(String label, List<Chromosome> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: items.isEmpty
                  ? const Center(child: Text('Trống', style: TextStyle(color: Colors.grey, fontSize: 10)))
                  : Wrap(
                      spacing: 2,
                      runSpacing: 2,
                      children: items.map((c) => SizedBox(
                        width: 30,
                        height: 40,
                        child: _buildChromosomeCard(c),
                      )).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
