import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/metaphase_image.dart';
import '../../repositories/image_storage_repository.dart';
import '../../repositories/workspace_repository.dart';

@lazySingleton
class UploadMultipleImages {
  final ImageStorageRepository storageRepository;
  final WorkspaceRepository workspaceRepository;

  UploadMultipleImages(this.storageRepository, this.workspaceRepository);

  Future<Either<Failure, void>> call(
    List<Uint8List> imagesBytes,
    String orderId, {
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      print('📦 [UseCase] Starting batch upload for ${imagesBytes.length} images');
      for (var i = 0; i < imagesBytes.length; i++) {
        final bytes = imagesBytes[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        print('⏳ [UseCase] Uploading image ${i + 1}/${imagesBytes.length}...');
        final uploadResult = await storageRepository.uploadRawImage(
          bytes: bytes,
          orderId: orderId,
          fileName: fileName,
        );

        final Either<Failure, void> saveResult = await uploadResult.fold(
          (failure) async => Left(failure),
          (downloadUrl) async {
            print('💾 [UseCase] Saving metadata to Firestore for image ${i + 1}');
            final imageRecord = MetaphaseImage(
              id: '${DateTime.now().millisecondsSinceEpoch}_$i',
              orderId: orderId,
              rawImageUrl: downloadUrl,
              status: AiProcessingStatus.uploaded,
              createdAt: DateTime.now(),
            );
            return await workspaceRepository.saveMetaphaseImageRecord(
              imageRecord,
            );
          },
        );

        if (saveResult.isLeft()) {
          print('❌ [UseCase] Failed at image ${i + 1}');
          return saveResult;
        }

        if (onProgress != null) {
          onProgress(i + 1, imagesBytes.length);
        }
      }
      print('✨ [UseCase] All images uploaded successfully');
      return const Right(null);
    } catch (e) {
      print('💥 [UseCase] Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
