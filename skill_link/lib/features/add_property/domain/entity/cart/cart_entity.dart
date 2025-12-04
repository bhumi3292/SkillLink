import 'package:equatable/equatable.dart';
import 'package:skill_link/features/add_property/domain/entity/property/property_entity.dart';

class CartItemEntity extends Equatable {
  final String? id;
  final PropertyEntity? property;
  final DateTime? createdAt;

  const CartItemEntity({
    this.id,
    this.property,
    this.createdAt,
  });

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      id: json['_id'] as String?,
      property: json['property'] != null 
          ? PropertyEntity.fromJson(json['property']) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'property': property?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, property, createdAt];
}

class CartEntity extends Equatable {
  final String? id;
  final String? userId;
  final List<CartItemEntity>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartEntity({
    this.id,
    this.userId,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory CartEntity.fromJson(Map<String, dynamic> json) {
    return CartEntity(
      id: json['_id'] as String?,
      userId: json['user'] as String?,
      items: (json['items'] as List?)?.map((item) => CartItemEntity.fromJson(item)).toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'items': items?.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, items, createdAt, updatedAt];
} 