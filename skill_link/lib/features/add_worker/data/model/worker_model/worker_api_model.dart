import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:skill_link/features/add_worker/domain/entity/worker/worker_entity.dart'; // Ensure this path is correct

part 'worker_api_model.g.dart'; // Don't forget to run `flutter pub run build_runner build`

@JsonSerializable()
class WorkerApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final List<String> images;
  final List<String>? videos;
  final String title;
  final String location;
  @JsonKey(name: 'categoryId')
  final String categoryId;
  final double price;
  final String? description;
  @JsonKey(name: 'worker')
  final String workerId;
  final double? averageRating;
  final int? numReviews;
  final int? viewCount;

  // Add timestamps from Mongoose schema
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkerApiModel({
    this.id,
    required this.images,
    this.videos,
    required this.title,
    required this.location,
    required this.categoryId,
    required this.price,
    this.description,
    required this.workerId,
    this.createdAt,
    this.updatedAt,
    this.averageRating,
    this.numReviews,
    this.viewCount,
  });

  // Factory constructor for deserialization from JSON
  // Normalizes nested objects (e.g. categoryId: { _id }) before using
  // the generated deserializer to keep parsing robust.
  factory WorkerApiModel.fromJson(Map<String, dynamic> json) {
    // Create a defensive copy and normalize common nested shapes that
    // the generated deserializer expects as simple types.
    final normalized = Map<String, dynamic>.from(json);

    // Normalize categoryId which may be an object
    if (normalized['categoryId'] is Map<String, dynamic>) {
      normalized['categoryId'] =
          normalized['categoryId']['_id']?.toString() ?? '';
    }

    // Normalize worker which may be an object
    if (normalized['worker'] is Map<String, dynamic>) {
      normalized['worker'] = normalized['worker']['_id']?.toString() ?? '';
    }

    // Normalize images: backend sometimes returns list of objects
    // or list of strings. Convert objects to a string path when possible.
    if (normalized['images'] is List) {
      final raw = normalized['images'] as List;
      normalized['images'] =
          raw
              .map((e) {
                if (e == null) return '';
                if (e is String) return e;
                if (e is Map<String, dynamic>) {
                  return (e['path'] ??
                              e['url'] ??
                              e['filename'] ??
                              e['_id'] ??
                              e['image'])
                          ?.toString() ??
                      '';
                }
                return e.toString();
              })
              .where((s) => (s).isNotEmpty)
              .toList();
    } else if (normalized['images'] == null) {
      normalized['images'] = <String>[];
    }

    // Normalize videos similarly
    if (normalized['videos'] is List) {
      final raw = normalized['videos'] as List;
      normalized['videos'] =
          raw
              .map((e) {
                if (e == null) return '';
                if (e is String) return e;
                if (e is Map<String, dynamic>) {
                  return (e['path'] ??
                              e['url'] ??
                              e['filename'] ??
                              e['_id'] ??
                              e['video'])
                          ?.toString() ??
                      '';
                }
                return e.toString();
              })
              .where((s) => (s).isNotEmpty)
              .toList();
    }

    // Normalize location: if it's an object, try to extract a readable address
    if (normalized['location'] is Map<String, dynamic>) {
      final loc = normalized['location'] as Map<String, dynamic>;
      normalized['location'] =
          (loc['address'] ??
                  loc['formattedAddress'] ??
                  loc['name'] ??
                  loc['description'])
              ?.toString() ??
          '';
    }

    // Ensure price can be parsed as a num/string that the generated code can handle
    if (normalized['price'] is String) {
      final p = double.tryParse(normalized['price']);
      if (p != null) normalized['price'] = p;
    }

    return _$WorkerApiModelFromJson(normalized);
  }

  // Method for serialization to JSON
  Map<String, dynamic> toJson() => _$WorkerApiModelToJson(this);

  // Mapping from WorkerApiModel (Data Layer) to WorkerEntity (Domain Layer)
  WorkerEntity toEntity() {
    return WorkerEntity(
      id: id,
      images: images,
      videos: videos,
      name: title,
      location: location,
      categoryId: categoryId,
      rate: price,
      description: description,
      // workerId in API represents the admin who added the worker in many
      // responses; map it to `addedByAdminId` on the entity.
      addedByAdminId: workerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      averageRating: averageRating,
      numReviews: numReviews,
      viewCount: viewCount,
    );
  }

  // Mapping from WorkerEntity (Domain Layer) to WorkerApiModel (Data Layer)
  factory WorkerApiModel.fromEntity(WorkerEntity entity) {
    return WorkerApiModel(
      id: entity.id,
      images: entity.images ?? [],
      videos: entity.videos,
      title: entity.name ?? '',
      location: entity.location ?? '',
      categoryId: entity.categoryId ?? '',
      price: entity.rate ?? 0.0, // Map entity.rate back to API price
      description: entity.description,
      workerId:
          entity.workerId ?? '', // Ensure non-nullable workerId is handled
      createdAt: entity.createdAt, // Added
      updatedAt: entity.updatedAt, // Added
      averageRating: entity.averageRating,
      numReviews: entity.numReviews,
      viewCount: entity.viewCount,
    );
  }

  @override
  List<Object?> get props => [
    id, images, videos, title, location,
    categoryId,
    price,
    description,
    workerId,
    createdAt,
    updatedAt,
    averageRating,
    numReviews,
    viewCount,
  ];

  @override
  bool get stringify => true;

  WorkerApiModel copyWith({
    String? id,
    List<String>? images,
    List<String>? videos,
    String? title,
    String? location,
    String? categoryId,
    double? price,
    String? description,
    String? workerId,
    DateTime? createdAt, // Added
    DateTime? updatedAt, // Added
  }) {
    return WorkerApiModel(
      id: id ?? this.id,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      title: title ?? this.title,
      location: location ?? this.location,
      categoryId: categoryId ?? this.categoryId, // Changed
      price: price ?? this.price,
      description: description ?? this.description,
      workerId: workerId ?? this.workerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      averageRating: averageRating ?? this.averageRating,
      numReviews: numReviews ?? this.numReviews,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
