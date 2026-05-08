import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';
import '../../core/errors/failures.dart';
import '../../domain/entities/chromosome.dart';
import '../../domain/entities/metaphase_image.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../models/chromosome_model.dart';
import '../models/metaphase_image_model.dart';

import 'package:dio/dio.dart';

@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Dio dio;

  WorkspaceRepositoryImpl(this.firestore, this.storage, this.dio);

  // We assume a single primary image per order for this implementation,
  // identified by 'default_image'.
  DocumentReference _getImageDocRef(String orderId, String imageId) {
    return firestore
        .collection('test_orders')
        .doc(orderId)
        .collection('metaphase_images')
        .doc(imageId);
  }

  @override
  Future<Either<Failure, void>> saveMetaphaseImageRecord(
    MetaphaseImage image,
  ) async {
    try {
      final model = MetaphaseImageModel.fromEntity(image);
      await _getImageDocRef(image.orderId, image.id).set(model.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, MetaphaseImage>> watchMetaphaseImageRecord(
    String orderId,
  ) {
    // Legacy support for single image watching - picks the first one or 'default_image'
    return firestore
        .collection('test_orders')
        .doc(orderId)
        .collection('metaphase_images')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return const Left(ServerFailure('No image records found'));
          }
          try {
            final model = MetaphaseImageModel.fromFirestore(
              snapshot.docs.first,
            );
            return Right(model);
          } catch (e) {
            return Left(ServerFailure(e.toString()));
          }
        });
  }

  @override
  Stream<Either<Failure, List<MetaphaseImage>>> watchMetaphaseImages(
    String orderId,
  ) {
    return firestore
        .collection('test_orders')
        .doc(orderId)
        .collection('metaphase_images')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            final images = snapshot.docs
                .map((doc) => MetaphaseImageModel.fromFirestore(doc))
                .toList();
            return Right(images);
          } catch (e) {
            return Left(ServerFailure(e.toString()));
          }
        });
  }

  @override
  Stream<Either<Failure, List<Chromosome>>> watchChromosomes(String orderId) {
    return _getImageDocRef(
      orderId,
      'default_image',
    ).collection('chromosomes').snapshots().map((snapshot) {
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
      // Note: Chromosomes are currently linked to a specific image.
      // This assumes we are updating chromosomes for the 'default_image' or we need to pass imageId.
      // For now, keeping it simple as the workspace logic currently only loads one image's chromosomes.
      await _getImageDocRef(orderId, 'default_image')
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

  @override
  Future<Either<Failure, void>> triggerAiAnalysis(String orderId) async {
    try {
      final response = await dio.post('/v1/orders/$orderId/analyze');
      if (response.statusCode == 200 || response.statusCode == 202) {
        return const Right(null);
      } else {
        return Left(ServerFailure('API trả về mã lỗi: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Chromosome>>> fetchChromosomesFromStorage(
    String orderId,
    String selectedImageId,
  ) async {
    try {
      final basePath = 'test_orders/$orderId/ai_predict/$selectedImageId';
      final manifestRef = storage.ref().child('$basePath/manifest.json');
      
      try {
        final manifestData = await manifestRef.getData();
        if (manifestData != null) {
          final String jsonString = utf8.decode(manifestData);
          final dynamic jsonData = jsonDecode(jsonString);
          
          if (jsonData is List) {
            final chromosomes = jsonData.map((item) {
              return Chromosome(
                id: item['id'] ?? item['filename'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                label: item['label'] ?? 'unassigned',
                imageUrl: item['url'],
                x: 0, y: 0, width: 40, height: 100, rotation: 0, isFlipped: false,
              );
            }).toList();
            return Right(chromosomes);
          }
        }
      } catch (_) {
        // Fallback to listAll if manifest fails
      }

      // Fallback
      final directoryRef = storage.ref().child(basePath);
      final listResult = await directoryRef.listAll();
      final List<Chromosome> chromosomes = [];

      for (var itemRef in listResult.items) {
        if (itemRef.name.endsWith('_detection.jpg') || itemRef.name == 'manifest.json') {
          continue;
        }

        final meta = await itemRef.getMetadata();
        final url = await itemRef.getDownloadURL();
        final currentLabel = meta.customMetadata?['current_label'] ?? 'unassigned';
        
        chromosomes.add(Chromosome(
          id: itemRef.name,
          label: currentLabel,
          imageUrl: url,
          x: 0, y: 0, width: 40, height: 100, rotation: 0, isFlipped: false,
        ));
      }
      return Right(chromosomes);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch chromosomes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveKaryogram(
    String orderId,
    String selectedImageId,
    List<Chromosome> chromosomes,
  ) async {
    try {
      final payload = chromosomes.map((c) => {
        'id': c.id,
        'label': c.label,
        'image_url': c.imageUrl,
      }).toList();

      final response = await dio.post(
        '/v1/orders/$orderId/karyogram/save',
        data: {
          'selected_image_id': selectedImageId,
          'chromosomes': payload,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        return const Right(null);
      } else {
        return Left(ServerFailure('API trả về mã lỗi: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
