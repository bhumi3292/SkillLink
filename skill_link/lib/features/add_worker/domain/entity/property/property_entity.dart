import 'package:equatable/equatable.dart';

class PropertyEntity extends Equatable {
  final String? id;
  final List<String>? images;
  final List<String>? videos;
  final String? title;
  final String? location;
  final int? bedrooms;
  final int? bathrooms;
  final String? categoryId;
  final double? price;
  final String? description;
  final String? workerId; // Optional - can be null for unauthenticated users
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyEntity({
    this.id,
    this.images,
    this.videos,
    this.title,
    this.location,
    this.bedrooms,
    this.bathrooms,
    this.categoryId,
    this.price,
    this.description,
    this.workerId,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a PropertyEntity from a JSON map (e.g., from API response)
  factory PropertyEntity.fromJson(Map<String, dynamic> json) {
    // Handle categoryId which can be either a string or an object
    String? categoryId;
    if (json['categoryId'] != null) {
      if (json['categoryId'] is String) {
        categoryId = json['categoryId'] as String;
      } else if (json['categoryId'] is Map<String, dynamic>) {
        categoryId = json['categoryId']['_id'] as String?;
      }
    }

    // Handle worker which can be either a string or an object
    String? workerId;
    if (json['worker'] != null) {
      if (json['worker'] is String) {
        workerId = json['worker'] as String;
      } else if (json['worker'] is Map<String, dynamic>) {
        workerId = json['worker']['_id'] as String?;
      }
    }

    return PropertyEntity(
      id: json['_id'] as String?,
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      videos: (json['videos'] as List?)?.map((e) => e as String).toList(),
      title: json['title'] as String?,
      location: json['location'] as String?,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      categoryId: categoryId,
      price:
          (json['price'] as num?)
              ?.toDouble(), // Handle num from JSON, convert to double
      description: json['description'] as String?,
      workerId: workerId,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Method to convert a PropertyEntity to a JSON map (e.g., for sending to API)
  Map<String, dynamic> toJson() {
    final json = {
      '_id': id,
      'images': images,
      'videos': videos,
      'title': title,
      'location': location,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'categoryId': categoryId,
      'price': price,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

    // Only add worker if it's not null
    if (workerId != null) {
      json['worker'] = workerId;
    }

    return json;
  }

  // Optional: copyWith method for immutability and easy updates
  PropertyEntity copyWith({
    String? id,
    List<String>? images,
    List<String>? videos,
    String? title,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? categoryId,
    double? price,
    String? description,
    String? workerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyEntity(
      id: id ?? this.id,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      title: title ?? this.title,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      description: description ?? this.description,
      workerId: workerId ?? this.workerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    images,
    videos,
    title,
    location,
    bedrooms,
    bathrooms,
    categoryId,
    price,
    description,
    workerId,
    createdAt,
    updatedAt,
  ];
}
