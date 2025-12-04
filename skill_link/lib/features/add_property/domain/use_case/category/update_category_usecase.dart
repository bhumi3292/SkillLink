// lib/features/add_property/domain/use_case/category/update_category_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';
import 'package:skill_link/features/add_property/domain/repository/category_repository.dart';

class UpdateCategoryUsecase {
  final ICategoryRepository repository;

  UpdateCategoryUsecase(this.repository);

  Future<Either<Failure, void>> call(CategoryEntity category) async {
    return await repository.updateCategory(category);
  }
}