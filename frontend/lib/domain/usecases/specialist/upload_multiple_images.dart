import 'dart:io';
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

  Future<Either<Failure, void>> call(List<File> imageFiles, String orderId) async {
    try {
      for (var i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        final uploadResult = await storageRepository.uploadRawImage(
          imageFile: file,
          orderId: orderId,
          fileName: fileName,
        );

        final Either<Failure, void> saveResult = await uploadResult.fold(
          (failure) async => Left(failure),
          (downloadUrl) async {
            final imageRecord = MetaphaseImage(
              id: '${DateTime.now().millisecondsSinceEpoch}_$i',
              orderId: orderId,
              rawImageUrl: downloadUrl,
              status: AiProcessingStatus.uploaded,
              createdAt: DateTime.now(),
            );
            return await workspaceRepository.saveMetaphaseImageRecord(imageRecord);
          },
        );

        if (saveResult.isLeft()) {
          return saveResult;
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
