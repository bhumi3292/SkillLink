import 'package:skill_link/features/favourite/domain/entity/cart/cart_entity.dart';
import 'package:skill_link/features/favourite/domain/repository/cart_repository.dart';

class GetCartUseCase {
  final CartRepository _cartRepository;

  GetCartUseCase(this._cartRepository);

  Future<CartEntity> call() async {
    return await _cartRepository.getCart();
  }
}
