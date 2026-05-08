import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chromosome.dart';

class ChromosomeModel {
  final String id;
  final String label;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final bool isFlipped;
  final String? imageUrl;

  ChromosomeModel({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    required this.isFlipped,
    this.imageUrl,
  });

  factory ChromosomeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> coords = data['coordinates'] ?? {};
    
    return ChromosomeModel(
      id: doc.id,
      label: data['label'] ?? '',
      x: (coords['x'] ?? 0).toDouble(),
      y: (coords['y'] ?? 0).toDouble(),
      width: (coords['w'] ?? 0).toDouble(),
      height: (coords['h'] ?? 0).toDouble(),
      rotation: (data['rotation'] ?? 0).toDouble(),
      isFlipped: data['is_flipped'] ?? false,
      imageUrl: data['image_url'] ?? data['imageUrl'],
    );
  }

  factory ChromosomeModel.fromEntity(Chromosome entity) {
    return ChromosomeModel(
      id: entity.id,
      label: entity.label,
      x: entity.x,
      y: entity.y,
      width: entity.width,
      height: entity.height,
      rotation: entity.rotation,
      isFlipped: entity.isFlipped,
      imageUrl: entity.imageUrl,
    );
  }

  Chromosome toEntity() {
    return Chromosome(
      id: id,
      label: label,
      x: x,
      y: y,
      width: width,
      height: height,
      rotation: rotation,
      isFlipped: isFlipped,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'coordinates': {'x': x, 'y': y, 'w': width, 'h': height},
      'rotation': rotation,
      'is_flipped': isFlipped,
      'image_url': imageUrl,
    };
  }
}

