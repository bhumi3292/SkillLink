import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'package:skill_link/features/add_property/data/model/property_model/property_api_model.dart';
import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart';

class PropertyRemoteDatasource {
  final Dio _dio;

  PropertyRemoteDatasource({required Dio dio}) : _dio = dio;

  /// Fetch all properties from the remote server
  Future<List<PropertyEntity>> getProperties() async {
    try {
      print('=== GET PROPERTIES API CALL ===');
      print('Fetching properties from: ${ApiEndpoints.getAllProperties}');

      final response = await _dio.get(ApiEndpoints.getAllProperties);

      print('Properties API Response: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle the response structure: { success: true, data: [...] }
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final List<dynamic> jsonList = responseData['data'] ?? [];
          print('Properties from data field: $jsonList');
          return jsonList.map((json) {
            print('Processing WorkerJSON: $json');
            return PropertyApiModel.fromJson(
              json as Map<String, dynamic>,
            ).toEntity();
          }).toList();
        } else if (responseData is List) {
          // Fallback for direct array response
          print('Properties as direct array: $responseData');
          return responseData.map((json) {
            print('Processing WorkerJSON: $json');
            return PropertyApiModel.fromJson(
              json as Map<String, dynamic>,
            ).toEntity();
          }).toList();
        } else {
          throw Exception('Invalid response format: ${response.data}');
        }
      } else {
        throw Exception(
          'Failed to get properties: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      print('DioException in getProperties: ${e.response?.data ?? e.message}');
      print('DioException type: ${e.type}');
      print('DioException status: ${e.response?.statusCode}');
      String errorMessage = 'Failed to get properties';

      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        errorMessage = data['message'] ?? errorMessage;
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Exception in getProperties: $e');
      throw Exception('Failed to get properties: $e');
    }
  }

  /// Fetch a single Workerby ID
  Future<PropertyEntity> getPropertyById(String propertyId) async {
    try {
      print('=== GET WorkerBY ID API CALL ===');
      final url = '${ApiEndpoints.getPropertyById}$propertyId';
      print('Fetching Workerfrom: $url');

      final response = await _dio.get(url);

      print('WorkerAPI Response: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle the response structure: { success: true, data: {...} }
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final json = responseData['data'] as Map<String, dynamic>;
          print('Workerfrom data field: $json');
          return PropertyApiModel.fromJson(json).toEntity();
        } else if (responseData is Map) {
          // Fallback for direct object response
          print('Workeras direct object: $responseData');
          return PropertyApiModel.fromJson(
            responseData as Map<String, dynamic>,
          ).toEntity();
        } else {
          throw Exception('Invalid response format: ${response.data}');
        }
      } else {
        throw Exception(
          'Failed to get property: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      print(
        'DioException in getPropertyById: ${e.response?.data ?? e.message}',
      );
      print('DioException type: ${e.type}');
      print('DioException status: ${e.response?.statusCode}');
      String errorMessage = 'Failed to get property';

      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        errorMessage = data['message'] ?? errorMessage;
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Exception in getPropertyById: $e');
      throw Exception('Failed to get property: $e');
    }
  }

  /// Add a new Workerwith images and videos
  Future<void> addProperty(
    PropertyEntity property,
    List<String> imagePaths,
    List<String> videoPaths,
  ) async {
    try {
      print('=== ADD WorkerAPI CALL ===');
      print('Adding Workerto: ${ApiEndpoints.createProperty}');

      final formData = FormData();

      // Add Workerfields
      formData.fields.addAll([
        MapEntry('title', property.title ?? ''),
        MapEntry('description', property.description ?? ''),
        MapEntry('location', property.location ?? ''),
        MapEntry('price', property.price.toString()),
        MapEntry('bedrooms', (property.bedrooms ?? 0).toString()),
        MapEntry('bathrooms', (property.bathrooms ?? 0).toString()),
      ]);

      // Add categoryId if not null
      if (property.categoryId != null && property.categoryId!.isNotEmpty) {
        formData.fields.add(MapEntry('categoryId', property.categoryId!));
      }

      // Add images
      for (int i = 0; i < imagePaths.length; i++) {
        final imageFile = await MultipartFile.fromFile(
          imagePaths[i],
          filename: 'image_$i.jpg',
        );
        formData.files.add(MapEntry('images', imageFile));
      }

      // Add videos
      for (int i = 0; i < videoPaths.length; i++) {
        final videoFile = await MultipartFile.fromFile(
          videoPaths[i],
          filename: 'video_$i.mp4',
        );
        formData.files.add(MapEntry('videos', videoFile));
      }

      print('Adding Workerwith form data');
      final response = await _dio.post(
        ApiEndpoints.createProperty,
        data: formData,
      );

      print('Add Workerresponse: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to add property: ${response.statusCode} - ${response.data}',
        );
      }

      print('Workeradded successfully');
      print('=== END ADD WorkerAPI CALL ===');
    } on DioException catch (e) {
      print('DioException in addProperty: ${e.response?.data ?? e.message}');
      throw Exception(
        'Failed to add Worker(Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Exception in addProperty: $e');
      throw Exception('Failed to add property: $e');
    }
  }

  /// Update an existing Workerwith new images and videos
  Future<void> updateProperty(
    String propertyId,
    PropertyEntity property,
    List<String> newImagePaths,
    List<String> newVideoPaths,
    List<String> existingImages,
    List<String> existingVideos,
  ) async {
    try {
      print('=== UPDATE WorkerAPI CALL ===');
      final url = ApiEndpoints.updateProperty(propertyId);
      print('Updating Workerat: $url');

      final formData = FormData();

      // Add Workerfields
      formData.fields.addAll([
        MapEntry('title', property.title ?? ''),
        MapEntry('description', property.description ?? ''),
        MapEntry('location', property.location ?? ''),
        MapEntry('price', property.price.toString()),
        MapEntry('bedrooms', (property.bedrooms ?? 0).toString()),
        MapEntry('bathrooms', (property.bathrooms ?? 0).toString()),
      ]);

      // Add categoryId if not null
      if (property.categoryId != null && property.categoryId!.isNotEmpty) {
        formData.fields.add(MapEntry('categoryId', property.categoryId!));
      }

      // Add existing images to keep
      if (existingImages.isNotEmpty) {
        formData.fields.add(
          MapEntry('existingImages', existingImages.join(',')),
        );
      }

      // Add existing videos to keep
      if (existingVideos.isNotEmpty) {
        formData.fields.add(
          MapEntry('existingVideos', existingVideos.join(',')),
        );
      }

      // Add new images
      for (int i = 0; i < newImagePaths.length; i++) {
        final imageFile = await MultipartFile.fromFile(
          newImagePaths[i],
          filename: 'image_$i.jpg',
        );
        formData.files.add(MapEntry('images', imageFile));
      }

      // Add new videos
      for (int i = 0; i < newVideoPaths.length; i++) {
        final videoFile = await MultipartFile.fromFile(
          newVideoPaths[i],
          filename: 'video_$i.mp4',
        );
        formData.files.add(MapEntry('videos', videoFile));
      }

      print('Updating Workerwith form data');
      final response = await _dio.put(url, data: formData);

      print('Update Workerresponse: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to update property: ${response.statusCode} - ${response.data}',
        );
      }

      print('Workerupdated successfully');
      print('=== END UPDATE WorkerAPI CALL ===');
    } on DioException catch (e) {
      print('DioException in updateProperty: ${e.response?.data ?? e.message}');
      throw Exception(
        'Failed to update Worker(Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Exception in updateProperty: $e');
      throw Exception('Failed to update property: $e');
    }
  }

  /// Delete a property
  Future<void> deleteProperty(String propertyId) async {
    try {
      print('=== DELETE WorkerAPI CALL ===');
      final url = '${ApiEndpoints.deleteProperty}$propertyId';
      print('Deleting Workerfrom: $url');

      final response = await _dio.delete(url);

      print('Delete Workerresponse: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete property: ${response.statusCode} - ${response.data}',
        );
      }

      print('Workerdeleted successfully');
      print('=== END DELETE WorkerAPI CALL ===');
    } on DioException catch (e) {
      print('DioException in deleteProperty: ${e.response?.data ?? e.message}');
      throw Exception(
        'Failed to delete Worker(Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Exception in deleteProperty: $e');
      throw Exception('Failed to delete property: $e');
    }
  }
}
