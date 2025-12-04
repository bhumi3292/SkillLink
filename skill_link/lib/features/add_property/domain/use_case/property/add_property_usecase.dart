import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart';
import 'package:skill_link/features/add_property/domain/repository/property_repository.dart';

class AddPropertyParams extends Equatable {
  final PropertyEntity property;
  final List<String> imagePaths;
  final List<String> videoPaths;

  const AddPropertyParams({
    required this.property,
    required this.imagePaths,
    required this.videoPaths,
  });

  @override
  List<Object?> get props => [property, imagePaths, videoPaths];
}

class AddPropertyUsecase implements UsecaseWithParams<void, AddPropertyParams> {
  final IPropertyRepository repository;

  AddPropertyUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(AddPropertyParams params) async {
    return await repository.addProperty(params.property, params.imagePaths, params.videoPaths);
  }
}

