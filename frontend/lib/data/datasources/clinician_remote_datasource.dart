import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

abstract class ClinicianRemoteDataSource {
  Future<List<Map<String, dynamic>>> getClinicians();
}

@LazySingleton(as: ClinicianRemoteDataSource)
class FirebaseClinicianRemoteDataSource implements ClinicianRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> getClinicians() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', whereIn: ['clinician'])
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'full_name': data['full_name'] ?? '',
        'role': data['role'] ?? '',
      };
    }).toList();
  }
}
