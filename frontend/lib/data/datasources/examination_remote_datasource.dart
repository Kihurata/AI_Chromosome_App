import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/examination_model.dart';
import '../../core/errors/exceptions.dart';

abstract class ExaminationRemoteDataSource {
  Future<void> createExamination(ExaminationModel examination);
  Future<ExaminationModel?> getExaminationByAppointmentId(String appointmentId);
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
      final snapshot = await firestore
          .collection('examinations')
          .where('appointment_id', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ExaminationModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException(message: "Lỗi khi truy vấn kết quả khám: ${e.toString()}");
    }
  }
}
