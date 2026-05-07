import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/failures.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/image_storage_repository.dart';

@LazySingleton(as: ImageStorageRepository)
class ImageStorageRepositoryImpl implements ImageStorageRepository {
  final FirebaseStorage firebaseStorage;

  ImageStorageRepositoryImpl(this.firebaseStorage);

  @override
  Future<Either<Failure, String>> uploadRawImage({
    required Uint8List bytes,
    required String orderId,
    required String fileName,
  }) async {
    try {
      debugPrint('🚀 [Storage] Starting upload: $fileName (Size: ${bytes.length} bytes)');
      final ref = firebaseStorage.ref().child('test_orders/$orderId/raw/$fileName');
      
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      debugPrint('✅ [Storage] Upload success: $fileName');
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      debugPrint('❌ [Storage] Firebase Error: [${e.code}] ${e.message}');
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e) {
      debugPrint('❌ [Storage] Unknown Error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
