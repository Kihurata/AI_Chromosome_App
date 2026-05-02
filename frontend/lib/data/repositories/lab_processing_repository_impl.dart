import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/sample.dart';
import '../../domain/repositories/lab_processing_repository.dart';

class LabProcessingRepositoryImpl implements LabProcessingRepository {
  final FirebaseFirestore firestore;

  LabProcessingRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, void>> updateSampleLabStatus(
    String sampleId,
    SampleStatus status,
  ) async {
    try {
      await firestore.collection('samples').doc(sampleId).update({
        'status': status.toFirestoreString(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
