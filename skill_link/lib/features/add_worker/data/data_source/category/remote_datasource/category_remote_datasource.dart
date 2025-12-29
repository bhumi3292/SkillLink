import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/features/add_worker/data/model/category_model/category_api_model.dart';
import 'package:skill_link/features/add_worker/domain/entity/category/category_entity.dart';

class CategoryRemoteDatasource {
  final Dio _dio;

  CategoryRemoteDatasource({required Dio dio}) : _dio = dio;

  Future<void> addCategory(CategoryEntity category) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createCategory,
        data: {
          'category_name': category.categoryName,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await _dio.delete(ApiEndpoints.deleteCategory(categoryId));
      if (response.statusCode != 200) {
        throw Exception('${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<CategoryEntity>> getCategories() async {
    try {
      // Logic from similar files usually checks response structure
      final response = await _dio.get(ApiEndpoints.getAllCategories);
      
      if (response.statusCode == 200) {
        // Adjusting for common response structure { success: true, data: [...] }
        final data = response.data;
        List<dynamic> list = [];
        if (data is Map && data['data'] is List) {
          list = data['data'];
        } else if (data is List) {
          list = data;
        }
        
        return list.map((e) => CategoryApiModel.fromJson(e).toEntity()).toList();
      } else {
        throw Exception('${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    try {
      if (category.id == null) {
        throw Exception('Category ID is required for update');
      }
      final response = await _dio.put(
        ApiEndpoints.updateCategory(category.id!),
        data: {
          'categoryName': category.categoryName,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
