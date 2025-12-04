// lib/features/add_property/domain/repository/category_repository.dart

import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';

abstract interface class ICategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, void>> addCategory(CategoryEntity category);

  Future<Either<Failure, void>> updateCategory(CategoryEntity category);

  Future<Either<Failure, void>> deleteCategory(String categoryId);
}