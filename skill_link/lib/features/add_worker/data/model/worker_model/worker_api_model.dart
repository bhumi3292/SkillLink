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
    this.createdAt, // Added
    this.updatedAt, // Added
  });

  // Factory constructor for deserialization from JSON
  // Normalizes nested objects (e.g. categoryId: { _id }) before using
  // the generated deserializer to keep parsing robust.
  factory WorkerApiModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['categoryId'] is Map<String, dynamic>) {
      normalized['categoryId'] =
          normalized['categoryId']['_id']?.toString() ?? '';
    }
    if (normalized['worker'] is Map<String, dynamic>) {
      normalized['worker'] = normalized['worker']['_id']?.toString() ?? '';
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
    );
  }

  // Mapping from WorkerEntity (Domain Layer) to WorkerApiModel (Data Layer)
  factory WorkerApiModel.fromEntity(WorkerEntity entity) {
    return WorkerApiModel(
      id: entity.id,
      images: entity.images ?? [], 
      videos: entity.videos,
      title: entity.name ?? '', 
      location:
          entity.location ?? '', 
      categoryId: entity.categoryId ?? '',
      price: entity.rate ?? 0.0, // Map entity.rate back to API price
      description: entity.description,
      workerId:
          entity.workerId ?? '', // Ensure non-nullable workerId is handled
      createdAt: entity.createdAt, // Added
      updatedAt: entity.updatedAt, // Added
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
    updatedAt, // Added timestamps
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
      createdAt: createdAt ?? this.createdAt, // Added
      updatedAt: updatedAt ?? this.updatedAt, // Added
    );
  }
}
