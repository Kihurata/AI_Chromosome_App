import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import 'package:injectable/injectable.dart';
import '../../entities/metaphase_image.dart';
import '../../repositories/image_storage_repository.dart';
import '../../repositories/workspace_repository.dart';

@lazySingleton
class UploadImageForAiAnalysis {
  final ImageStorageRepository storageRepository;
  final WorkspaceRepository workspaceRepository;

  UploadImageForAiAnalysis(this.storageRepository, this.workspaceRepository);

  Future<Either<Failure, void>> call(File imageFile, String orderId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final uploadResult = await storageRepository.uploadRawImage(
      imageFile: imageFile,
      orderId: orderId,
      fileName: fileName,
    );

    return uploadResult.fold(
      (failure) => Left(failure),
      (downloadUrl) async {
        final imageRecord = MetaphaseImage(
          id: 'default_image', // Primary image
          orderId: orderId,
          rawImageUrl: downloadUrl,
          status: AiProcessingStatus.uploaded,
          createdAt: DateTime.now(),
        );
        return await workspaceRepository.saveMetaphaseImageRecord(imageRecord);
      },
    );
  }
}
