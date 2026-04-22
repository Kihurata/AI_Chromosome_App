import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatients();
  Future<void> createPatient(PatientModel patient);
  Future<bool> checkIdentityExists(String identityCard);
}

class FirebasePatientRemoteDataSource implements PatientRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<PatientModel>> getPatients() async {
    final snapshot = await _firestore
        .collection('patients')
        .orderBy('created_at', descending: true)
        .get();
    
    return snapshot.docs.map((doc) => PatientModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> createPatient(PatientModel patient) async {
    await _firestore.collection('patients').add(patient.toFirestore());
  }

  @override
  Future<bool> checkIdentityExists(String identityCard) async {
    final snapshot = await _firestore
        .collection('patients')
        .where('identity_card', isEqualTo: identityCard)
        .limit(1)
        .get();
    
    return snapshot.docs.isNotEmpty;
  }
}
