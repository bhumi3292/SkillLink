import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class WorkerProfileRemoteDataSource {
  final ApiService _apiService;

  WorkerProfileRemoteDataSource(this._apiService);

  Future<ExploreWorkerEntity> getWorkerById(String id) async {
    try {
      final response = await _apiService.dio.get(ApiEndpoints.getWorkerById(id));
      if (response.statusCode == 200) {
        return ExploreWorkerEntity.fromJson(response.data['data']);
      } else {
        throw Exception("Failed to fetch worker details");
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<ExploreWorkerEntity> updateWorker(
    String id,
    Map<String, dynamic> data,
    List<File>? newImages,
  ) async {
    try {
      final formData = FormData.fromMap(data);

      if (newImages != null && newImages.isNotEmpty) {
        for (var file in newImages) {
          final fileName = file.path.split('/').last;
          final ext = fileName.split('.').last.toLowerCase();
          final type = (ext == 'png' || ext == 'jpg' || ext == 'jpeg')
              ? 'image/$ext'
              : 'image/jpeg';
            
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType.parse(type),
            ),
          ));
        }
      }

      final response = await _apiService.dio.put(
        ApiEndpoints.updateWorker(id),
        data: formData,
      );

      if (response.statusCode == 200) {
        return ExploreWorkerEntity.fromJson(response.data['data']);
      } else {
        throw Exception("Failed to update worker");
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> deactivateWorker(String id) async {
    try {
      final response = await _apiService.dio.delete(ApiEndpoints.deleteWorker(id));
      if (response.statusCode != 200) {
         throw Exception("Failed to deactivate worker");
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
