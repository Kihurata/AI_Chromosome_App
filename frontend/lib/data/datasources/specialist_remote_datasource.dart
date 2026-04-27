import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SpecialistRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSpecialists();
}

class FirebaseSpecialistRemoteDataSource implements SpecialistRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> getSpecialists() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'specialist')
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'full_name': data['full_name'] ?? '',
        'role': data['role'] ?? '',
        'email': data['email'] ?? '',
      };
    }).toList();
  }
}
