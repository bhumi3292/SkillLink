import 'package:skill_link/features/add_property/domain/entity/cart/cart_entity.dart';

abstract class ICartDataSource {
  Future<CartEntity> getCart();
  Future<CartEntity> addToCart(String propertyId);
  Future<CartEntity> removeFromCart(String propertyId);
  Future<void> clearCart();
}
