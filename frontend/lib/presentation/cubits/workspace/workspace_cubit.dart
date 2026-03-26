import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/chromosome_model.dart';

class WorkspaceState {
  final List<ChromosomeModel> chromosomes;
  final String? selectedId;

  WorkspaceState({
    required this.chromosomes,
    this.selectedId,
  });

  WorkspaceState copyWith({
    List<ChromosomeModel>? chromosomes,
    String? selectedId,
  }) {
    return WorkspaceState(
      chromosomes: chromosomes ?? this.chromosomes,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

class WorkspaceCubit extends Cubit<WorkspaceState> {
  WorkspaceCubit() : super(WorkspaceState(chromosomes: []));

  // Sync with Riverpod raw stream
  void syncFromStream(List<ChromosomeModel> streamData) {
    // Priority: If we are not currently dragging something, 
    // or we want to overwrite local state with DB source.
    emit(state.copyWith(chromosomes: streamData));
  }

  // Handle local dragging/rotation (Temporary state)
  void updatePosition(String id, double newX, double newY) {
    final updatedList = state.chromosomes.map((item) {
      if (item.id == id) {
        return ChromosomeModel(
          id: item.id,
          label: item.label,
          x: newX,
          y: newY,
          width: item.width,
          height: item.height,
          rotation: item.rotation,
          isFlipped: item.isFlipped,
        );
      }
      return item;
    }).toList();

    emit(state.copyWith(chromosomes: updatedList, selectedId: id));
  }

  void selectItem(String? id) {
    emit(state.copyWith(selectedId: id));
  }
}
