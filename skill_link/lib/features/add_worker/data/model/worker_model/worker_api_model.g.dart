// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerApiModel _$WorkerApiModelFromJson(
  Map<String, dynamic> json,
) => WorkerApiModel(
  id: json['_id'] as String?,
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  videos: (json['videos'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String,
  location: json['location'] as String,
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
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  numReviews: (json['numReviews'] as num?)?.toInt(),
  viewCount: (json['viewCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$WorkerApiModelToJson(WorkerApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'images': instance.images,
      'videos': instance.videos,
      'title': instance.title,
      'location': instance.location,
      'categoryId': instance.categoryId,
      'price': instance.price,
      'description': instance.description,
      'worker': instance.workerId,
      'averageRating': instance.averageRating,
      'numReviews': instance.numReviews,
      'viewCount': instance.viewCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
