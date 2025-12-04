import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:skill_link/features/favourite/domain/entity/cart/cart_entity.dart';
import 'package:skill_link/features/add_property/data/model/property_model/property_api_model.dart';
import 'package:skill_link/features/favourite/domain/entity/cart/cart_item_entity.dart';

part 'cart_api_model.g.dart';

@JsonSerializable()
class CartApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final String user;
  final List<CartItemApiModel> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartApiModel({
    this.id,
    required this.user,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory CartApiModel.fromJson(Map<String, dynamic> json) =>
      _$CartApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartApiModelToJson(this);

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      user: user,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CartApiModel.fromEntity(CartEntity entity) {
    return CartApiModel(
      id: entity.id,
      user: entity.user,
      items:
          entity.items
              ?.map((item) => CartItemApiModel.fromEntity(item))
              .toList() ??
          [],
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, user, items, createdAt, updatedAt];

  @override
  bool get stringify => true;
}

@JsonSerializable()
class CartItemApiModel extends Equatable {
  @JsonKey(name: '_id')
  final String? id;
  final PropertyApiModel property;

  const CartItemApiModel({this.id, required this.property});

  factory CartItemApiModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemApiModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemApiModelToJson(this);

  CartItemEntity toEntity() {
    return CartItemEntity(id: id, property: property.toEntity());
  }

  factory CartItemApiModel.fromEntity(CartItemEntity entity) {
    return CartItemApiModel(
      id: entity.id,
      property: PropertyApiModel.fromEntity(entity.property),
    );
  }

  @override
  List<Object?> get props => [id, property];

  @override
  bool get stringify => true;
}
