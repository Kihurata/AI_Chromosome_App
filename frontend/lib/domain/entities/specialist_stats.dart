import 'package:equatable/equatable.dart';

class SpecialistStats extends Equatable {
  final int pending;
  final int analyzing;
  final int waitingApproval;
  final int completed;

  const SpecialistStats({
    this.pending = 0,
    this.analyzing = 0,
    this.waitingApproval = 0,
    this.completed = 0,
  });

  int get total => pending + analyzing + waitingApproval + completed;

  @override
  List<Object> get props => [pending, analyzing, waitingApproval, completed];
}
