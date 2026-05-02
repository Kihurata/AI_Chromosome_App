import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class ImageStorageRepository {
  Future<Either<Failure, String>> uploadRawImage({
    required File imageFile,
    required String orderId,
    required String fileName,
  });
}
