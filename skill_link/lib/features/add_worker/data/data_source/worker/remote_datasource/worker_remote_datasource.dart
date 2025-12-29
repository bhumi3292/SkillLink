import 'package:dio/dio.dart';
import 'package:skill_link/app/constant/api_endpoints.dart';
import 'dart:convert';

import 'package:skill_link/features/add_worker/data/model/worker_model/worker_api_model.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart';

class WorkerRemoteDatasource {
  final Dio _dio;

  WorkerRemoteDatasource({required Dio dio}) : _dio = dio;

  /// Fetch all properties from the remote server
  Future<List<WorkerEntity>> getWorkers() async {
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
            return WorkerApiModel.fromJson(
              json as Map<String, dynamic>,
            ).toEntity();
          }).toList();
        } else if (responseData is List) {
          // Fallback for direct array response
          print('Properties as direct array: $responseData');
          return responseData.map((json) {
            print('Processing WorkerJSON: $json');
            return WorkerApiModel.fromJson(
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
  Future<WorkerEntity> getWorkerById(String workerId) async {
    try {
      print('=== GET WorkerBY ID API CALL ===');
      final url = ApiEndpoints.getWorkerById(workerId);
      print('Fetching Worker from: $url');

      final response = await _dio.get(url);

      print('WorkerAPI Response: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle the response structure: { success: true, data: {...} }
        if (responseData is Map<String, dynamic> &&
            responseData['success'] == true) {
          final json = responseData['data'] as Map<String, dynamic>;
          print('Worker from data field: $json');
          return WorkerApiModel.fromJson(json).toEntity();
        } else if (responseData is Map) {
          // Fallback for direct object response
          print('Workeras direct object: $responseData');
          return WorkerApiModel.fromJson(
            responseData as Map<String, dynamic>,
          ).toEntity();
        } else {
          throw Exception('Invalid response format: ${response.data}');
        }
      } else {
        throw Exception(
          'Failed to get worker: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      print(
        'DioException in getWorkerById: ${e.response?.data ?? e.message}',
      );
      print('DioException type: ${e.type}');
      print('DioException status: ${e.response?.statusCode}');
      String errorMessage = 'Failed to get worker';

      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        errorMessage = data['message'] ?? errorMessage;
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Exception in getWorkerById: $e');
      throw Exception('Failed to get worker: $e');
    }
  }

  /// Add a new Workerwith images and videos
  Future<void> addWorker(
    WorkerEntity worker,
    List<String> imagePaths,
    List<String> videoPaths, {
    String? licensePath,
    String? identityCardPath,
  }) async {
    try {
      print('=== ADD Worker API CALL ===');
      print('Adding Worker to: ${ApiEndpoints.createWorker}');
      // Validate required fields on the client before sending
      final missing = <String>[];
      if (worker.name == null || worker.name!.trim().isEmpty) {
        missing.add('name/title');
      }
      if (worker.description == null || worker.description!.trim().isEmpty) {
        missing.add('description');
      }
      if (worker.location == null || worker.location!.trim().isEmpty) {
        missing.add('location');
      }
      if (worker.rate == null) missing.add('rate/price');
      if (worker.categoryId == null || worker.categoryId!.trim().isEmpty) {
        missing.add('categoryId');
      }

      if (missing.isNotEmpty) {
        throw Exception('Missing required fields: ${missing.join(', ')}');
      }

      final formData = FormData();

      // Add Worker fields. Send both legacy and new names for compatibility.
      formData.fields.addAll([
        MapEntry('title', worker.name ?? ''),
        MapEntry('name', worker.name ?? ''),
        MapEntry('description', worker.description ?? ''),
        MapEntry('location', worker.location ?? ''),
        MapEntry('price', worker.rate?.toString() ?? '0'),
        MapEntry('rate', worker.rate?.toString() ?? '0'),
        MapEntry('experience', worker.experience ?? '0'),
      ]);

      // Add license file
      if (licensePath != null && licensePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'license',
            await MultipartFile.fromFile(
              licensePath,
              filename: 'license_${DateTime.now().millisecondsSinceEpoch}.pdf',
            ),
          ),
        );
      }

      // Add identityCard file
      if (identityCardPath != null && identityCardPath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'identityCard',
            await MultipartFile.fromFile(
              identityCardPath,
              filename: 'id_${DateTime.now().millisecondsSinceEpoch}.pdf',
            ),
          ),
        );
      }

      // Add categoryId if not null
      if (worker.categoryId != null && worker.categoryId!.isNotEmpty) {
        formData.fields.add(MapEntry('categoryId', worker.categoryId!));
      }

      // Try to include coordinates in multiple formats for backend compatibility.
      // Backend expects `coordinates` as a JSON string (e.g. "[lng, lat]").
      double? lat;
      double? lng;
      if (worker.coordinates != null && worker.coordinates!.isNotEmpty) {
        final raw = worker.coordinates!.trim();
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List && decoded.length == 2) {
            // Assume [lng, lat]
            lng = (decoded[0] as num?)?.toDouble() ?? 0.0;
            lat = (decoded[1] as num?)?.toDouble() ?? 0.0;
          } else if (decoded is Map) {
            if (decoded['lat'] != null && decoded['lng'] != null) {
              lat = (decoded['lat'] as num?)?.toDouble();
              lng = (decoded['lng'] as num?)?.toDouble();
            }
          }
        } catch (_) {
          // Not JSON - try comma separated 'lat,lng' or 'lng,lat'
          final parts = raw.split(',').map((s) => s.trim()).toList();
          if (parts.length == 2) {
            final a = double.tryParse(parts[0]);
            final b = double.tryParse(parts[1]);
            if (a != null && b != null) {
              // Heuristic: if latitude is in typical range (-90..90) assume parts[0] is lat
              if (a.abs() <= 90 && b.abs() <= 180) {
                lat = a;
                lng = b;
              } else if (b.abs() <= 90 && a.abs() <= 180) {
                lat = b;
                lng = a;
              }
            }
          }
        }

        // If we could parse lat/lng add them to the form data
        if (lat != null && lng != null) {
          formData.fields.add(MapEntry('latitude', lat.toString()));
          formData.fields.add(MapEntry('longitude', lng.toString()));
          // Send coordinates as [lng, lat] JSON string which backend expects
          formData.fields.add(MapEntry('coordinates', jsonEncode([lng, lat])));
        }
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
        ApiEndpoints.createWorker,
        data: formData,
      );

      print('Add Worker response: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to add worker: ${response.statusCode} - ${response.data}',
        );
      }

      print('Workeradded successfully');
      print('=== END ADD WorkerAPI CALL ===');
    } on DioException catch (e) {
      print('DioException in addWorker: ${e.response?.data ?? e.message}');
      throw Exception(
        'Failed to add Worker(Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Exception in addWorker: $e');
      throw Exception('Failed to add worker: $e');
    }
  }

  /// Update an existing Workerwith new images and videos
  Future<void> updateWorker(
    String workerId,
    WorkerEntity worker,
    List<String> newImagePaths,
    List<String> newVideoPaths,
    List<String> existingImages,
    List<String> existingVideos,
  ) async {
    try {
      print('=== UPDATE WorkerAPI CALL ===');
      final url = ApiEndpoints.updateWorker(workerId);
      print('Updating Worker at: $url');

      final formData = FormData();

      // Add Workerfields
      formData.fields.addAll([
        MapEntry('title', worker.name ?? ''),
        MapEntry('description', worker.description ?? ''),
        MapEntry('location', worker.location ?? ''),
        MapEntry('price', worker.rate?.toString() ?? '0'),
      ]);

      // Add categoryId if not null
      if (worker.categoryId != null && worker.categoryId!.isNotEmpty) {
        formData.fields.add(MapEntry('categoryId', worker.categoryId!));
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

      // Include coordinates if provided on the worker entity (same parsing logic as add)
      double? lat;
      double? lng;
      if (worker.coordinates != null && worker.coordinates!.isNotEmpty) {
        final raw = worker.coordinates!.trim();
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List && decoded.length == 2) {
            lng = (decoded[0] as num?)?.toDouble();
            lat = (decoded[1] as num?)?.toDouble();
          } else if (decoded is Map) {
            if (decoded['lat'] != null && decoded['lng'] != null) {
              lat = (decoded['lat'] as num?)?.toDouble();
              lng = (decoded['lng'] as num?)?.toDouble();
            }
          }
        } catch (_) {
          final parts = raw.split(',').map((s) => s.trim()).toList();
          if (parts.length == 2) {
            final a = double.tryParse(parts[0]);
            final b = double.tryParse(parts[1]);
            if (a != null && b != null) {
              if (a.abs() <= 90 && b.abs() <= 180) {
                lat = a;
                lng = b;
              } else if (b.abs() <= 90 && a.abs() <= 180) {
                lat = b;
                lng = a;
              }
            }
          }
        }

        if (lat != null && lng != null) {
          formData.fields.add(MapEntry('latitude', lat.toString()));
          formData.fields.add(MapEntry('longitude', lng.toString()));
          formData.fields.add(MapEntry('coordinates', jsonEncode([lng, lat])));
        }
      }

      print('Updating Workerwith form data');
      final response = await _dio.put(url, data: formData);

      print('Update Workerresponse: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to update worker: ${response.statusCode} - ${response.data}',
        );
      }

      print('Workerupdated successfully');
      print('=== END UPDATE WorkerAPI CALL ===');
    } on DioException catch (e) {
      print('DioException in updateWorker: ${e.response?.data ?? e.message}');
      throw Exception(
        'Failed to update Worker(Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Exception in updateWorker: $e');
      throw Exception('Failed to update worker: $e');
    }
  }

  /// Delete a worker
  Future<void> deleteWorker(String workerId) async {
    try {
      print('=== DELETE Worker API CALL ===');
      final url = ApiEndpoints.deleteWorker(workerId);
      print('Deleting Worker from: $url');

      final response = await _dio.delete(url);

      print('Delete Workerresponse: ${response.data}');
      print('Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete worker: ${response.statusCode} - ${response.data}',
        );
      }

      print('Workerdeleted successfully');
      print('=== END DELETE WorkerAPI CALL ===');
    } on DioException catch (e) {
      print('DioException in deleteWorker: ${e.response?.data ?? e.message}');
      throw Exception(
        'Failed to delete Worker(Dio Error): ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('Exception in deleteWorker: $e');
      throw Exception('Failed to delete worker: $e');
    }
  }
}
