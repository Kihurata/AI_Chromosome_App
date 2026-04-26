import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/patient_model.dart';
import '../../core/errors/exceptions.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatients();
  Future<void> addPatient(PatientModel patient);
  Future<void> updatePatient(PatientModel patient);
  Future<PatientModel> getPatientById(String id);
}

@LazySingleton(as: PatientRemoteDataSource)
class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final FirebaseFirestore firestore;

  PatientRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<PatientModel>> getPatients() async {
    try {
      final snapshot = await firestore.collection('patients').get();
      return snapshot.docs
          .map((doc) => PatientModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: "Không thể lấy dữ liệu bệnh nhân");
    }
  }

  @override
  Future<void> addPatient(PatientModel patient) async {
    try {
      await firestore.collection('patients').add(patient.toFirestore());
    } catch (e) {
      throw ServerException(message: "Không thể thêm bệnh nhân mới");
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      final doc = await firestore.collection('patients').doc(id).get();
      return PatientModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: "Không thể lấy dữ liệu bệnh nhân");
    }
  }

  @override
  Future<void> updatePatient(PatientModel patient) async {
    try {
      await firestore
          .collection('patients')
          .doc(patient.id)
          .update(patient.toFirestore());
    } catch (e) {
      throw ServerException(message: "Không thể cập nhật thông tin bệnh nhân");
    }
  }
}
