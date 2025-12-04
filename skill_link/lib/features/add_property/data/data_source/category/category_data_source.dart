// lib/features/add_property/data/data_source/category_data_source.dart


import 'package:skill_link/features/add_property/domain/entity/category/category_entity.dart';

abstract interface class ICategoryDataSource {
  Future<List<CategoryEntity>> getCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String categoryId);
}