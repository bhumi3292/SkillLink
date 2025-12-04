import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:skill_link/features/favourite/domain/entity/cart/cart_entity.dart';
import 'package:skill_link/features/favourite/domain/usecase/get_cart_usecase.dart';
import 'package:skill_link/features/favourite/domain/usecase/add_to_cart_usecase.dart';
import 'package:skill_link/features/favourite/domain/usecase/remove_from_cart_usecase.dart';
import 'package:skill_link/features/favourite/domain/usecase/clear_cart_usecase.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class GetCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String propertyId;

  const AddToCartEvent(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class RemoveFromCartEvent extends CartEvent {
  final String propertyId;

  const RemoveFromCartEvent(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class ClearCartEvent extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartEntity cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final ClearCartUseCase _clearCartUseCase;

  CartBloc({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required ClearCartUseCase clearCartUseCase,
  }) : _getCartUseCase = getCartUseCase,
       _addToCartUseCase = addToCartUseCase,
       _removeFromCartUseCase = removeFromCartUseCase,
       _clearCartUseCase = clearCartUseCase,
       super(CartInitial()) {
    on<GetCartEvent>(_onGetCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<ClearCartEvent>(_onClearCart);
  }

  Future<void> _onGetCart(GetCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _getCartUseCase();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cart = await _addToCartUseCase(event.propertyId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cart = await _removeFromCartUseCase(event.propertyId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await _clearCartUseCase();
      emit(const CartLoaded(CartEntity(user: '', items: [])));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
