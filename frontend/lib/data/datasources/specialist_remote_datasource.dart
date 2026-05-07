import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:injectable/injectable.dart';

abstract class SpecialistRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSpecialists();
  Future<List<Map<String, dynamic>>> getAllSpecialists();
}

@Injectable(as: SpecialistRemoteDataSource)
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

  @override
  Future<List<Map<String, dynamic>>> getAllSpecialists() async {
    return await getSpecialists();
  }
}
