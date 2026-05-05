import 'package:equatable/equatable.dart';
import '../../../../domain/entities/sample.dart';

abstract class SampleDetailState extends Equatable {
  const SampleDetailState();

  @override
  List<Object?> get props => [];
}

class SampleDetailInitial extends SampleDetailState {}

class SampleDetailLoading extends SampleDetailState {}

class SampleDetailSuccess extends SampleDetailState {
  final Sample sample;

  const SampleDetailSuccess(this.sample);

  @override
  List<Object?> get props => [sample];
}

class SampleDetailError extends SampleDetailState {
  final String message;

  const SampleDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
