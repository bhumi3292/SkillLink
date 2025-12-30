import 'package:skill_link/cores/network/api_service.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/features/banner/data/models/banner_model.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:skill_link/app/service_locator/service_locator.dart';

class BannerRemoteDatasource {
  final ApiService apiService;

  BannerRemoteDatasource({required this.apiService});

  Future<List<BannerModel>> fetchActiveBanners() async {
    final response = await apiService.dio.get(
      ApiEndpoints.publicActiveBanners.replaceFirst(ApiEndpoints.baseUrl, ''),
    );
    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Admin operations (create/update/delete) can be added here when needed
  Future<List<BannerModel>> fetchAdminBanners() async {
    final response = await apiService.dio.get(
      ApiEndpoints.adminBanners.replaceFirst(ApiEndpoints.baseUrl, ''),
    );
    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BannerModel> createBanner({
    required Map<String, dynamic> body,
    File? image,
  }) async {
    final form = FormData();
    body.forEach((k, v) {
      if (v != null) form.fields.add(MapEntry(k, v.toString()));
    });
    if (image != null) {
      final name = image.path.split(Platform.pathSeparator).last;
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(image.path, filename: name),
        ),
      );
    }

    final response = await apiService.dio.post(
      ApiEndpoints.adminBanners.replaceFirst(ApiEndpoints.baseUrl, ''),
      data: form,
    );
    final data = response.data as Map<String, dynamic>;
    return BannerModel.fromJson(data['data']);
  }

  Future<BannerModel> updateBanner({
    required String id,
    required Map<String, dynamic> body,
    File? image,
  }) async {
    final form = FormData();
    body.forEach((k, v) {
      if (v != null) form.fields.add(MapEntry(k, v.toString()));
    });
    if (image != null) {
      final name = image.path.split(Platform.pathSeparator).last;
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(image.path, filename: name),
        ),
      );
    }

    final response = await apiService.dio.put(
      '${ApiEndpoints.adminBanners.replaceFirst(ApiEndpoints.baseUrl, '')}/$id',
      data: form,
    );
    final data = response.data as Map<String, dynamic>;
    return BannerModel.fromJson(data['data']);
  }

  Future<void> deleteBanner(String id) async {
    await apiService.dio.delete(
      '${ApiEndpoints.adminBanners.replaceFirst(ApiEndpoints.baseUrl, '')}/$id',
    );
  }
}
