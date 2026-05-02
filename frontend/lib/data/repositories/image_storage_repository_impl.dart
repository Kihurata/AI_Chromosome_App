import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/image_storage_repository.dart';

class ImageStorageRepositoryImpl implements ImageStorageRepository {
  final FirebaseStorage firebaseStorage;

  ImageStorageRepositoryImpl({required this.firebaseStorage});

  @override
  Future<Either<Failure, String>> uploadRawImage({
    required File imageFile,
    required String orderId,
    required String fileName,
  }) async {
    try {
      final ref = firebaseStorage.ref().child('test_orders/$orderId/raw/$fileName');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
