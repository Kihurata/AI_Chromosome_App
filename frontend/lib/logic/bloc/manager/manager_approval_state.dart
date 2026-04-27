import 'package:equatable/equatable.dart';

abstract class ManagerApprovalState extends Equatable {
  const ManagerApprovalState();

  @override
  List<Object?> get props => [];
}

class ManagerApprovalInitial extends ManagerApprovalState {}

class ManagerApprovalLoading extends ManagerApprovalState {}

class ManagerApprovalSuccess extends ManagerApprovalState {
  final String message;

  const ManagerApprovalSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ManagerApprovalError extends ManagerApprovalState {
  final String message;

  const ManagerApprovalError(this.message);

  @override
  List<Object?> get props => [message];
}
