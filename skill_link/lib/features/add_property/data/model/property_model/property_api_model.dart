import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart'; // Ensure this path is correct

part 'property_api_model.g.dart'; // Don't forget to run `flutter pub run build_runner build`

@JsonSerializable()
class PropertyApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final List<String> images;
  final List<String>? videos;
  final String title;
  final String location;
  final int? bedrooms;
  final int? bathrooms;
  @JsonKey(name: 'categoryId') // Matches your Mongoose schema's field name
  final String categoryId; // Changed from categoryName to categoryId
  final double price;
  final String? description;
  @JsonKey(name: 'worker') // Matches your Mongoose schema's field name
  final String workerId;

  // Add timestamps from Mongoose schema
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PropertyApiModel({
    this.id,
    required this.images,
    this.videos,
    required this.title,
    required this.location,
    this.bedrooms,
    this.bathrooms,
    required this.categoryId, // Changed
    required this.price,
    this.description,
    required this.workerId,
    this.createdAt, // Added
    this.updatedAt, // Added
  });

  // Factory constructor for deserialization from JSON
  factory PropertyApiModel.fromJson(Map<String, dynamic> json) {
    return PropertyApiModel(
      id: json['_id']?.toString(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      videos: json['videos'] != null ? List<String>.from(json['videos']) : [],
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      bedrooms:
          json['bedrooms'] is int
              ? json['bedrooms']
              : int.tryParse(json['bedrooms']?.toString() ?? ''),
      bathrooms:
          json['bathrooms'] is int
              ? json['bathrooms']
              : int.tryParse(json['bathrooms']?.toString() ?? ''),
      categoryId:
          json['categoryId'] is Map<String, dynamic>
              ? json['categoryId']['_id']?.toString() ?? ''
              : json['categoryId']?.toString() ?? '',
      price:
          json['price'] is double
              ? json['price']
              : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      description: json['description']?.toString(),
      workerId:
          json['worker'] is Map<String, dynamic>
              ? json['worker']['_id']?.toString() ?? ''
              : json['worker']?.toString() ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  // Method for serialization to JSON
  Map<String, dynamic> toJson() => _$PropertyApiModelToJson(this);

  // Mapping from PropertyApiModel (Data Layer) to PropertyEntity (Domain Layer)
  PropertyEntity toEntity() {
    return PropertyEntity(
      id: id,
      images: images,
      videos: videos,
      title: title,
      location: location,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      categoryId: categoryId, // Changed
      price: price,
      description: description,
      workerId: workerId,
      createdAt: createdAt, // Added
      updatedAt: updatedAt, // Added
    );
  }

  // Mapping from PropertyEntity (Domain Layer) to PropertyApiModel (Data Layer)
  factory PropertyApiModel.fromEntity(PropertyEntity entity) {
    return PropertyApiModel(
      id: entity.id,
      images: entity.images ?? [], // Ensure non-nullable images list is handled
      videos: entity.videos,
      title: entity.title ?? '', // Ensure non-nullable title is handled
      location:
          entity.location ?? '', // Ensure non-nullable location is handled
      bedrooms: entity.bedrooms,
      bathrooms: entity.bathrooms,
      categoryId:
          entity.categoryId ?? '', // Ensure non-nullable categoryId is handled
      price: entity.price ?? 0.0, // Ensure non-nullable price is handled
      description: entity.description,
      workerId:
          entity.workerId ?? '', // Ensure non-nullable workerId is handled
      createdAt: entity.createdAt, // Added
      updatedAt: entity.updatedAt, // Added
    );
  }

  @override
  List<Object?> get props => [
    id, images, videos, title, location, bedrooms, bathrooms,
    categoryId,
    price,
    description,
    workerId,
    createdAt,
    updatedAt, // Added timestamps
  ];

  @override
  bool get stringify => true;

  PropertyApiModel copyWith({
    String? id,
    List<String>? images,
    List<String>? videos,
    String? title,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? categoryId, // Changed
    double? price,
    String? description,
    String? workerId,
    DateTime? createdAt, // Added
    DateTime? updatedAt, // Added
  }) {
    return PropertyApiModel(
      id: id ?? this.id,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      title: title ?? this.title,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      categoryId: categoryId ?? this.categoryId, // Changed
      price: price ?? this.price,
      description: description ?? this.description,
      workerId: workerId ?? this.workerId,
      createdAt: createdAt ?? this.createdAt, // Added
      updatedAt: updatedAt ?? this.updatedAt, // Added
    );
  }
}
