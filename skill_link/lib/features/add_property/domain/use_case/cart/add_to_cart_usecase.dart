import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/app/use_case/usecase.dart';
import 'package:skill_link/cores/error/failure.dart';
import 'package:skill_link/features/add_property/domain/entity/cart/cart_entity.dart';
import 'package:skill_link/features/add_property/domain/repository/cart/cart_repository.dart';

class AddToCartParams extends Equatable {
  final String propertyId;

  const AddToCartParams({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

class AddToCartUsecase implements UsecaseWithParams<CartEntity, AddToCartParams> {
  final ICartRepository _cartRepository;

  AddToCartUsecase({required ICartRepository cartRepository}) 
      : _cartRepository = cartRepository;

  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams params) async {
    try {
      final result = await _cartRepository.addToCart(params.propertyId);
      return result;
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
} 