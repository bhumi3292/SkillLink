import 'package:equatable/equatable.dart';
import 'package:skill_link/features/favourite/domain/entity/cart/cart_item_entity.dart';

class CartEntity extends Equatable {
  final String? id;
  final String user;
  final List<CartItemEntity>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartEntity({
    this.id,
    required this.user,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, user, items, createdAt, updatedAt];

  @override
  bool get stringify => true;
}
