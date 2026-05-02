import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/chromosome.dart';
import '../../domain/entities/metaphase_image.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/workspace_repository.dart';

@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final FirebaseFirestore firestore;

  WorkspaceRepositoryImpl(this.firestore);

  // We assume a single primary image per order for this implementation, 
  // identified by 'default_image'.
  DocumentReference _getImageDocRef(String orderId) {
    return firestore
        .collection('test_orders')
        .doc(orderId)
        .collection('metaphase_images')
        .doc('default_image');
  }

  @override
  Future<Either<Failure, void>> saveMetaphaseImageRecord(MetaphaseImage image) async {
    try {
      final model = MetaphaseImageModel.fromEntity(image);
      await _getImageDocRef(image.orderId).set(model.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, MetaphaseImage>> watchMetaphaseImageRecord(String orderId) {
    return _getImageDocRef(orderId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return const Left(ServerFailure('Image record not found'));
      }
      try {
        final model = MetaphaseImageModel.fromFirestore(snapshot);
        return Right(model);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Stream<Either<Failure, List<Chromosome>>> watchChromosomes(String orderId) {
    return _getImageDocRef(orderId)
        .collection('chromosomes')
        .snapshots()
        .map((snapshot) {
      try {
        final chromosomes = snapshot.docs
            .map((doc) => ChromosomeModel.fromFirestore(doc).toEntity())
            .toList();
        return Right(chromosomes);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  @override
  Future<Either<Failure, void>> updateChromosomePosition(
    String orderId,
    Chromosome chromosome,
  ) async {
    try {
      final model = ChromosomeModel.fromEntity(chromosome);
      await _getImageDocRef(orderId)
          .collection('chromosomes')
          .doc(chromosome.id)
          .update(model.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitResultForApproval(String orderId) async {
    try {
      await firestore.collection('test_orders').doc(orderId).update({
        'status': 'IN_REVIEW',
        'updated_at': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
