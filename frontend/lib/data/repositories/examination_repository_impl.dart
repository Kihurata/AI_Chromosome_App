import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/examination.dart';
import '../../domain/repositories/examination_repository.dart';
import '../models/examination_model.dart';

class ExaminationRepositoryImpl implements ExaminationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Either<Failure, void>> createExamination(Examination examination) async {
    try {
      final model = ExaminationModel.fromEntity(examination);
      await _firestore
          .collection('examinations')
          .doc(examination.id.isEmpty ? null : examination.id)
          .set(model.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Examination?>> getExaminationByAppointmentId(
      String appointmentId) async {
    try {
      final snapshot = await _firestore
          .collection('examinations')
          .where('appointment_id', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return const Right(null);
      return Right(ExaminationModel.fromFirestore(snapshot.docs.first).toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
