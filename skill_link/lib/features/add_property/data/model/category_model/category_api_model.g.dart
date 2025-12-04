// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryApiModel _$CategoryApiModelFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['category_name'],
  );
  return CategoryApiModel(
    id: json['_id'] as String?,
    categoryName: json['category_name'] as String,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
  );
}

Map<String, dynamic> _$CategoryApiModelToJson(CategoryApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'category_name': instance.categoryName,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
