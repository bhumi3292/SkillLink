import 'package:skill_link/features/favourite/data/datasource/cart_api_service.dart';
import 'package:skill_link/features/favourite/domain/entity/cart/cart_entity.dart';
import 'package:skill_link/features/favourite/domain/repository/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartApiService _cartApiService;

  CartRepositoryImpl(this._cartApiService);

  @override
  Future<CartEntity> getCart() async {
    try {
      final cartApiModel = await _cartApiService.getCart();
      return cartApiModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  @override
  Future<CartEntity> addToCart(String propertyId) async {
    try {
      final cartApiModel = await _cartApiService.addToCart(propertyId);
      return cartApiModel.toEntity();
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  @override
  Future<CartEntity> removeFromCart(String propertyId) async {
    try {
      final cartApiModel = await _cartApiService.removeFromCart(propertyId);
      return cartApiModel.toEntity();
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _cartApiService.clearCart();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
