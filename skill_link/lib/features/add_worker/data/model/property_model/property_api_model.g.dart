// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyApiModel _$PropertyApiModelFromJson(
  Map<String, dynamic> json,
) => PropertyApiModel(
  id: json['_id'] as String?,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  videos: (json['videos'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String,
  location: json['location'] as String,
  bedrooms: (json['bedrooms'] as num?)?.toInt(),
  bathrooms: (json['bathrooms'] as num?)?.toInt(),
  categoryId: json['categoryId'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String?,
  workerId: json['worker'] as String,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PropertyApiModelToJson(PropertyApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'images': instance.images,
      'videos': instance.videos,
      'title': instance.title,
      'location': instance.location,
      'bedrooms': instance.bedrooms,
      'bathrooms': instance.bathrooms,
      'categoryId': instance.categoryId,
      'price': instance.price,
      'description': instance.description,
      'worker': instance.workerId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
