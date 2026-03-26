import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chromosome_model.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// Provider to stream chromosomes for a specific metaphase image
// Path: test_orders/{orderId}/metaphase_images/{imageId}/chromosomes
final chromosomesStreamProvider = StreamProvider.family<List<ChromosomeModel>, String>((ref, path) {
  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('$path/chromosomes')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => ChromosomeModel.fromFirestore(doc)).toList();
  });
});
