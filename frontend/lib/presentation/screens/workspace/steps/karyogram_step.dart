import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/workspace/workspace_cubit.dart';
import '../../../../domain/entities/chromosome.dart';
import '../../../widgets/shared/form/app_buttons.dart';


class KaryogramStep extends StatelessWidget {
  const KaryogramStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pool of unassigned chromosomes
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'NST chưa phân loại',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                      builder: (context, state) {
                        final unassigned = state.chromosomes
                            .where((c) => c.label == '' || c.label == 'unassigned')
                            .toList();

                        // If empty but the whole list is empty, generate dummies for testing
                        // Normally this comes from step 2 via FastAPI.
                        if (unassigned.isEmpty && state.chromosomes.isEmpty) {
                          return Center(
                            child: AppPrimaryButton(
                              text: 'Tạo dữ liệu mẫu',
                              onPressed: () {
                                final dummies = List.generate(
                                  46,
                                  (index) => Chromosome(
                                    id: 'chr_$index',
                                    label: 'unassigned',
                                    x: 0,
                                    y: 0,
                                    width: 40,
                                    height: 100,
                                    rotation: 0,
                                    isFlipped: false,
                                  ),
                                );
                                context.read<WorkspaceCubit>().syncFromStream(dummies);
                              },
                            ),
                          );
                        }

                        return DragTarget<String>(
                          onAcceptWithDetails: (details) {
                            context.read<WorkspaceCubit>().assignChromosomeLabel(details.data, 'unassigned');
                          },
                          builder: (context, candidateData, rejectedData) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: unassigned.length,
                              itemBuilder: (context, index) {
                                final chromo = unassigned[index];
                                return _DraggableChromosome(chromosome: chromo);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Karyogram Grid
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Lưới Karyogram',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: 24, // 1 to 22 + X + Y
                      itemBuilder: (context, index) {
                        final label = index < 22 ? (index + 1).toString() : (index == 22 ? 'X' : 'Y');
                        return _KaryotypeSlot(label: label);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraggableChromosome extends StatelessWidget {
  final Chromosome chromosome;

  const _DraggableChromosome({required this.chromosome});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: chromosome.id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 40,
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.line_weight, color: Colors.blue),
        ),
      ),
    );
  }
}

class _KaryotypeSlot extends StatelessWidget {
  final String label;

  const _KaryotypeSlot({required this.label});

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        context.read<WorkspaceCubit>().assignChromosomeLabel(details.data, label);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return Container(
          decoration: BoxDecoration(
            color: isHovering ? Colors.green.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovering ? Colors.green : Colors.grey.shade300,
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                  builder: (context, state) {
                    final matched = state.chromosomes.where((c) => c.label == label).toList();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: matched.map((chromo) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _DraggableChromosome(chromosome: chromo),
                      )).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
