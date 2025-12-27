import 'package:skill_link/features/favourite/domain/entity/cart/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart();
  Future<CartEntity> addToCart(String workerId);
  Future<CartEntity> removeFromCart(String workerId);
  Future<void> clearCart();
}
