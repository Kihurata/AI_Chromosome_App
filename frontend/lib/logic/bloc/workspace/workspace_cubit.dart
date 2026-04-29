import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chromosome.dart';
import '../../../domain/usecases/specialist/update_chromosome_position.dart';

class WorkspaceState {
  final List<Chromosome> chromosomes;
  final String? selectedId;

  WorkspaceState({
    required this.chromosomes,
    this.selectedId,
  });

  WorkspaceState copyWith({
    List<Chromosome>? chromosomes,
    String? selectedId,
  }) {
    return WorkspaceState(
      chromosomes: chromosomes ?? this.chromosomes,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

class WorkspaceCubit extends Cubit<WorkspaceState> {
  final UpdateChromosomePosition updatePositionUsecase;
  final String orderId;

  WorkspaceCubit({
    required this.updatePositionUsecase,
    required this.orderId,
  }) : super(WorkspaceState(chromosomes: []));

  // Sync with Riverpod raw stream
  void syncFromStream(List<Chromosome> streamData) {
    // Priority: If we are not currently dragging something, 
    // or we want to overwrite local state with DB source.
    emit(state.copyWith(chromosomes: streamData));
  }

  // Handle local dragging/rotation (Temporary state + background sync)
  void updatePosition(String id, double newX, double newY) {
    Chromosome? updatedChromosome;
    final updatedList = state.chromosomes.map((item) {
      if (item.id == id) {
        updatedChromosome = item.copyWith(x: newX, y: newY);
        return updatedChromosome!;
      }
      return item;
    }).toList();

    // 1. Immediate UI update for smooth dragging
    emit(state.copyWith(chromosomes: updatedList, selectedId: id));

    // 2. Background sync to Firestore
    if (updatedChromosome != null) {
      updatePositionUsecase(orderId, updatedChromosome!);
    }
  }

  void selectItem(String? id) {
    emit(state.copyWith(selectedId: id));
  }
}

