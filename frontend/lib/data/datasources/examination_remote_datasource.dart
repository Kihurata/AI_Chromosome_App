import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/examination_model.dart';
import '../../core/errors/exceptions.dart';

abstract class ExaminationRemoteDataSource {
  Future<void> createExamination(ExaminationModel examination);
  Future<ExaminationModel?> getExaminationByAppointmentId(String appointmentId);
  Future<List<ExaminationModel>> getExaminationsByPatientId(String patientId);
}

@LazySingleton(as: ExaminationRemoteDataSource)
class ExaminationRemoteDataSourceImpl implements ExaminationRemoteDataSource {
  final FirebaseFirestore firestore;

  ExaminationRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> createExamination(ExaminationModel examination) async {
    try {
      await firestore
          .collection('examinations')
          .doc(examination.id.isEmpty ? null : examination.id)
          .set(examination.toFirestore());
    } catch (e) {
      throw ServerException(message: "Không thể lưu kết quả khám bệnh: ${e.toString()}");
    }
  }

  @override
  Future<ExaminationModel?> getExaminationByAppointmentId(String appointmentId) async {
    try {
      print('DEBUG: Querying examination for appointmentId: $appointmentId');
      final snapshot = await firestore
          .collection('examinations')
          .where('appointment_id', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('DEBUG: No examination found for appointmentId: $appointmentId');
        return null;
      }
      print('DEBUG: Found examination for appointmentId: $appointmentId');
      return ExaminationModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('DEBUG: Error in getExaminationByAppointmentId: $e');
      throw ServerException(message: "Lỗi khi truy vấn kết quả khám: ${e.toString()}");
    }
  }

  @override
  Future<List<ExaminationModel>> getExaminationsByPatientId(String patientId) async {
    try {
      print('DEBUG: Querying examinations for patientId: $patientId');
      final snapshot = await firestore
          .collection('examinations')
          .where('patient_id', isEqualTo: patientId)
          .get();

      print('DEBUG: Found ${snapshot.docs.length} examinations');
      return snapshot.docs.map((doc) => ExaminationModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('DEBUG: Error in getExaminationsByPatientId: $e');
      throw ServerException(message: "Lỗi khi truy vấn lịch sử khám: ${e.toString()}");
    }
  }
}
