// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartApiModel _$CartApiModelFromJson(Map<String, dynamic> json) => CartApiModel(
  id: json['_id'] as String?,
  user: json['user'] as String,
  items:
      (json['items'] as List<dynamic>)
          .map((e) => CartItemApiModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CartApiModelToJson(CartApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'items': instance.items,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CartItemApiModel _$CartItemApiModelFromJson(Map<String, dynamic> json) =>
    CartItemApiModel(
      id: json['_id'] as String?,
      property:
          json['property'] == null
              ? PropertyApiModel(
                id: '',
                images: [],
                title: 'Unknown',
                location: '',
                categoryId: '',
                price: 0.0,
                workerId: '',
              )
              : PropertyApiModel.fromJson(
                json['property'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$CartItemApiModelToJson(CartItemApiModel instance) =>
    <String, dynamic>{'_id': instance.id, 'property': instance.property};
