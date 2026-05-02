import 'package:equatable/equatable.dart';

class Chromosome extends Equatable {
  final String id;
  final String label;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final bool isFlipped;

  const Chromosome({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    required this.isFlipped,
  });

  Chromosome copyWith({
    String? id,
    String? label,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    bool? isFlipped,
  }) {
    return Chromosome(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  @override
  List<Object?> get props => [
        id,
        label,
        x,
        y,
        width,
        height,
        rotation,
        isFlipped,
      ];
}
