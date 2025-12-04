import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/domain/entity/cart/cart_entity.dart';

abstract class ICartRepository {
  Future<Either<Failure, CartEntity>> addToCart(String propertyId);
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> removeFromCart(String propertyId);
  Future<Either<Failure, void>> clearCart();
} 