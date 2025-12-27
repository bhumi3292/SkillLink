import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_worker/domain/entity/cart/cart_entity.dart';

abstract class ICartRepository {
  Future<Either<Failure, CartEntity>> addToCart(String workerId);
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> removeFromCart(String workerId);
  Future<Either<Failure, void>> clearCart();
}
