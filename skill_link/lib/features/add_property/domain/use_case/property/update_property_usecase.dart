// lib/features/add_property/domain/use_case/update_property_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart';
import 'package:skill_link/features/add_property/domain/repository/property_repository.dart';

class UpdatePropertyUsecase {
  final IPropertyRepository repository;

  UpdatePropertyUsecase(this.repository);

  Future<Either<Failure, void>> call(
      String propertyId,
      PropertyEntity property,
      List<String> newImagePaths,
      List<String> newVideoPaths,
      List<String> existingImages,
      List<String> existingVideos,
      ) async {
    return await repository.updateProperty(
      propertyId,
      property,
      newImagePaths,
      newVideoPaths,
      existingImages,
      existingVideos,
    );
  }
}
