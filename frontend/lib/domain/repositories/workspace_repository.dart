import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chromosome.dart';
import '../entities/metaphase_image.dart';

abstract class WorkspaceRepository {
  Stream<Either<Failure, List<Chromosome>>> watchChromosomes(String orderId);
  
  Future<Either<Failure, void>> updateChromosomePosition(
    String orderId,
    Chromosome chromosome,
  );
  
  Future<Either<Failure, void>> submitResultForApproval(String orderId);
  
  Future<Either<Failure, void>> saveMetaphaseImageRecord(
    MetaphaseImage image,
  );

  Stream<Either<Failure, MetaphaseImage>> watchMetaphaseImageRecord(String orderId);

  Stream<Either<Failure, List<MetaphaseImage>>> watchMetaphaseImages(String orderId);
  
  Future<Either<Failure, void>> triggerAiAnalysis(String orderId);
}
