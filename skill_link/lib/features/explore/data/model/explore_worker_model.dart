import 'package:skill_link/features/explore/domain/entity/explore_worker_entity.dart';
import 'package:latlong2/latlong.dart';

class ExploreWorkerModel extends ExploreWorkerEntity {
  ExploreWorkerModel({
    super.id,
    super.images,
    super.videos,
    super.title,
    super.location,
    super.coordinates,
    super.bedrooms,
    super.bathrooms,
    super.categoryId,
    super.categoryName,
    super.price,
    super.description,
    super.workerId,
    super.workerName,
    super.workerEmail,
    super.workerPhone,
    super.skills,
    super.averageRating,
    super.numReviews,
    super.viewCount,
  });

  factory ExploreWorkerModel.fromJson(Map<String, dynamic> json) {
    // Parse coordinates if available
    LatLng? coords;
    if (json['location'] != null &&
        json['location'] is Map &&
        json['location']['coordinates'] is List &&
        json['location']['coordinates'].length == 2) {
      final c = json['location']['coordinates'];
      coords = LatLng(c[1], c[0]); // Lat, Lng
    }

    // Parse address string: attempt many possible keys returned by different APIs
    String? address;
    if (json['location'] is String) {
      address = json['location']?.toString();
    } else if (json['location'] is Map) {
      final loc = json['location'] as Map<String, dynamic>;
      address =
          loc['address']?.toString() ??
          loc['formattedAddress']?.toString() ??
          loc['formatted_address']?.toString() ??
          loc['display_name']?.toString() ??
          loc['name']?.toString() ??
          loc['description']?.toString() ??
          loc['fullAddress']?.toString() ??
          loc['address_line']?.toString();

      // If address still missing, try to build from components
      if ((address == null || address.isEmpty)) {
        final parts = <String>[];
        for (final key in [
          'street',
          'street1',
          'street_address',
          'road',
          'city',
          'town',
          'village',
          'suburb',
          'state',
          'region',
          'country',
        ]) {
          final value = loc[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            parts.add(value.toString().trim());
          }
        }
        if (parts.isNotEmpty) {
          address = parts.join(', ');
        }
      }
    }

    // Fallback top-level fields
    if ((address == null || address.isEmpty) && json['address'] is String) {
      address = json['address']?.toString();
    }
    if ((address == null || address.isEmpty) &&
        json['formattedAddress'] is String) {
      address = json['formattedAddress']?.toString();
    }

    return ExploreWorkerModel(
      id: json['_id']?.toString(),
      images: _parseStringList(json['images']),
      videos: _parseStringList(json['videos']),
      title: json['title']?.toString(),
      location: address,
      coordinates: coords,
      bedrooms:
          json['bedrooms'] != null
              ? int.tryParse(json['bedrooms'].toString())
              : null,
      bathrooms:
          json['bathrooms'] != null
              ? int.tryParse(json['bathrooms'].toString())
              : null,
      categoryId:
          (json['categoryId'] is Map && json['categoryId'] != null)
              ? json['categoryId']['_id']?.toString()
              : json['categoryId']?.toString(),
      categoryName:
          (json['categoryId'] is Map && json['categoryId'] != null)
              ? json['categoryId']['category_name']?.toString()
              : null,
      price:
          json['price'] != null
              ? double.tryParse(json['price'].toString())
              : null,
      description: json['description']?.toString(),
      workerId:
          (json['worker'] is Map && json['worker'] != null)
              ? json['worker']['_id']?.toString()
              : json['worker']?.toString(),
      workerName:
          (json['worker'] is Map && json['worker'] != null)
              ? json['worker']['fullName']?.toString()
              : null,
      workerEmail:
          (json['worker'] is Map && json['worker'] != null)
              ? json['worker']['email']?.toString()
              : null,
      workerPhone:
          (json['worker'] is Map && json['worker'] != null)
              ? json['worker']['phoneNumber']?.toString()
              : null,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      numReviews: json['numReviews'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    try {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((e) => e?.toString().replaceAll('\\', '/') ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (value is String) {
        // sometimes APIs return a comma-separated string
        final parts =
            value
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
        return parts.map((e) => e.replaceAll('\\', '/')).toList();
      }
    } catch (e) {
      print('ExploreWorkerModel._parseStringList error: $e');
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'images': images,
      'videos': videos,
      'title': title,
      'location': location,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'categoryId': categoryId,
      'category_name': categoryName,
      'price': price,
      'description': description,
      'workerId': workerId,
      'workerName': workerName,
      'workerEmail': workerEmail,
      'workerPhone': workerPhone,
      'skills': skills,
    };
  }
}
