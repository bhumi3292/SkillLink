import 'package:skill_link/features/favourite/domain/repository/cart_repository.dart';

class ClearCartUseCase {
  final CartRepository _cartRepository;

  ClearCartUseCase(this._cartRepository);

  Future<void> call() async {
    return await _cartRepository.clearCart();
  }
}
