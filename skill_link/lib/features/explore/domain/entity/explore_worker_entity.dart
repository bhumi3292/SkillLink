import 'package:latlong2/latlong.dart';

class ExploreWorkerEntity {
  final String? id;
  final List<String>? images;
  final List<String>? videos;
  final String? title;
  final String? location; // Address string
  final LatLng? coordinates; // Geo-coordinates

  final int? bedrooms;
  final int? bathrooms;
  final String? categoryId;
  final String? categoryName;
  final double? price;
  final double? minPrice;
  final double? maxPrice;
  final String? availabilityStatus;
  final String? description;
  final String? workerId;
  final String? workerName;
  final String? workerEmail;

  final String? workerPhone;
  final List<String>? skills;
  final double? averageRating;
  final int? numReviews;
  final int? viewCount;

  final int? experience;
  final String? licenseUrl;
  final String? identityCardUrl;

  ExploreWorkerEntity({
    this.id,
    this.images,
    this.videos,
    this.title,
    this.location,
    this.coordinates,
    this.bedrooms,
    this.bathrooms,
    this.categoryId,
    this.categoryName,
    this.price,
    this.minPrice,
    this.maxPrice,
    this.availabilityStatus,
    this.description,
    this.workerId,
    this.workerName,
    this.workerEmail,
    this.workerPhone,
    this.skills,
    this.averageRating,
    this.numReviews,
    this.viewCount,
    this.experience,
    this.licenseUrl,
    this.identityCardUrl,
  });

  factory ExploreWorkerEntity.fromJson(Map<String, dynamic> json) {
    // Parse coordinates if available
    LatLng? coords;
    if (json['location'] != null &&
        json['location'] is Map &&
        json['location']['coordinates'] is List &&
        json['location']['coordinates'].length == 2) {
      final c = json['location']['coordinates'];
      coords = LatLng(c[1], c[0]); // Lat, Lng
    }

    // Parse address string (could be in 'location' or 'address' depending on API,
    // assuming 'location' might be a complex object in some responses or just string in others)
    String? address;
    if (json['location'] is String) {
      address = json['location'];
    } else if (json['location'] is Map) {
      // If location is an object, look for an address/formattedAddress field inside,
      // or fall back to string representation if needed.
      // Adjust based on actual API response structure for address text.
      address =
          json['location']['address'] ?? json['location']['formattedAddress'];
    }
    // Fallback: Check if there is a separate address field at root
    if (address == null && json['address'] is String) {
      address = json['address'];
    }

    return ExploreWorkerEntity(
      id: json['_id'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      title: json['title'],
      location: address,
      coordinates: coords,
      categoryId: json['categoryId']?['_id'],
      categoryName: json['categoryId']?['category_name'],
      price: (json['price'] as num?)?.toDouble(),
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      availabilityStatus: json['availabilityStatus'] ?? 'Available',
      description: json['description'],
      workerId: json['worker']?['_id'],
      workerName: json['worker']?['fullName'],
      workerEmail: json['worker']?['email'],
      workerPhone: json['worker']?['phoneNumber'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      numReviews: json['numReviews'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      experience: json['experience'] as int?,
      licenseUrl: json['licenseUrl'] as String?,
      identityCardUrl: json['identityCardUrl'] as String?,
    );
  }
}
