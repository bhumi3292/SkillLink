import 'package:skill_link/features/add_property/domain/repository/cart/cart_repository.dart';
import 'package:skill_link/features/add_property/data/data_source/cart/remote_datasource/cart_remote_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/domain/entity/cart/cart_entity.dart';

class CartRepositoryImpl implements ICartRepository {
  final CartRemoteDatasource cartDataSource;

  CartRepositoryImpl({required this.cartDataSource});

  @override
  Future<Either<Failure, CartEntity>> addToCart(String propertyId) async {
    try {
      final result = await cartDataSource.addToCart(propertyId);
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final result = await cartDataSource.getCart();
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart(String propertyId) async {
    try {
      final result = await cartDataSource.removeFromCart(propertyId);
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await cartDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
