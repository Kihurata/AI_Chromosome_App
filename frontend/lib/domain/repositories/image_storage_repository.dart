import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class ImageStorageRepository {
  Future<Either<Failure, String>> uploadRawImage({
    required Uint8List bytes,
    required String orderId,
    required String fileName,
  });
}
