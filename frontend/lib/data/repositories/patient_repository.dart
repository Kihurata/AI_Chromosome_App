import '../datasources/patient_remote_datasource.dart';
import '../models/patient_model.dart';

abstract class PatientRepository {
  Future<List<PatientModel>> getAllPatients();
  Future<void> registerPatient(PatientModel patient);
  Future<List<PatientModel>> searchPatients(String query);
  Future<bool> identityExists(String identityCard);
}

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PatientModel>> getAllPatients() {
    return remoteDataSource.getPatients();
  }

  @override
  Future<void> registerPatient(PatientModel patient) {
    return remoteDataSource.createPatient(patient);
  }

  @override
  Future<bool> identityExists(String identityCard) {
    return remoteDataSource.checkIdentityExists(identityCard);
  }

  @override
  Future<List<PatientModel>> searchPatients(String query) async {
    // Tạm thời reuse logic filter tại client từ clinical_repository hoặc tối ưu bằng Firestore Query sau
    final all = await remoteDataSource.getPatients();
    if (query.isEmpty) return all;
    
    final q = query.toUpperCase();
    return all.where((p) => 
      p.fullName.toUpperCase().contains(q) || 
      p.phone.contains(query) || 
      p.identityCard.contains(query)
    ).toList();
  }
}
