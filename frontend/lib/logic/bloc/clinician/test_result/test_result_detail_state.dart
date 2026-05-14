import 'package:equatable/equatable.dart';
import '../../../../domain/entities/test_order.dart';
import '../../../../domain/entities/chromosome.dart';
import '../../workspace/workspace_cubit.dart';

class TestResultDetailState extends Equatable {
  final TestOrder? testOrder;
  final List<Chromosome> chromosomes;
  final WorkspaceStatus status;
  final String? errorMessage;

  const TestResultDetailState({
    this.testOrder,
    this.chromosomes = const [],
    this.status = WorkspaceStatus.initial,
    this.errorMessage,
  });

  TestResultDetailState copyWith({
    TestOrder? testOrder,
    List<Chromosome>? chromosomes,
    WorkspaceStatus? status,
    String? errorMessage,
  }) {
    return TestResultDetailState(
      testOrder: testOrder ?? this.testOrder,
      chromosomes: chromosomes ?? this.chromosomes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [testOrder, chromosomes, status, errorMessage];
}
