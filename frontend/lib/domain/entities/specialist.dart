import 'package:equatable/equatable.dart';

class Specialist extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final int activeWorkload;

  const Specialist({
    required this.id,
    required this.fullName,
    required this.email,
    this.activeWorkload = 0,
  });

  Specialist copyWith({
    String? id,
    String? fullName,
    String? email,
    int? activeWorkload,
  }) {
    return Specialist(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      activeWorkload: activeWorkload ?? this.activeWorkload,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, activeWorkload];
}
