import 'package:skill_link/features/add_worker/domain/entity/cart/cart_entity.dart';

abstract class ICartDataSource {
  Future<CartEntity> getCart();
  Future<CartEntity> addToCart(String workerId);
  Future<CartEntity> removeFromCart(String workerId);
  Future<void> clearCart();
}
