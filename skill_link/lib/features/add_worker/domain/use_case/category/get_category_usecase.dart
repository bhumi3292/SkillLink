// lib/features/add_worker/domain/use_case/add_property_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/entity/property/property_entity.dart';
import 'package:skill_link/features/add_worker/domain/repository/property_repository.dart';

class AddPropertyUsecase {
  final IPropertyRepository repository;

  AddPropertyUsecase(this.repository);

  Future<Either<Failure, void>> call(
    PropertyEntity property,
    List<String> imagePaths,
    List<String> videoPaths,
  ) async {
    return await repository.addProperty(property, imagePaths, videoPaths);
  }
}
