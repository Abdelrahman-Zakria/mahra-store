import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// The cart has just been initialized, no data yet
class CartInitial extends CartState {
  const CartInitial();
}

/// An async operation is in progress (e.g., saving to persistence)
class CartLoading extends CartState {
  const CartLoading();
}

/// Item was successfully added to the cart
class CartItemAddSuccess extends CartState {
  final CartEntity cart;
  final String addedProductId;

  const CartItemAddSuccess({
    required this.cart,
    required this.addedProductId,
  });

  @override
  List<Object?> get props => [cart, addedProductId];
}

/// Item was successfully removed from the cart
class CartItemRemoveSuccess extends CartState {
  final CartEntity cart;
  final String removedProductId;

  const CartItemRemoveSuccess({
    required this.cart,
    required this.removedProductId,
  });

  @override
  List<Object?> get props => [cart, removedProductId];
}

/// Quantity of a cart item was changed successfully
class CartQuantityChangeSuccess extends CartState {
  final CartEntity cart;
  final String productId;
  final int newQuantity;

  const CartQuantityChangeSuccess({
    required this.cart,
    required this.productId,
    required this.newQuantity,
  });

  @override
  List<Object?> get props => [cart, productId, newQuantity];
}

/// Cart was cleared successfully
class CartClearSuccess extends CartState {
  final CartEntity cart;

  const CartClearSuccess({required this.cart});

  @override
  List<Object?> get props => [cart];
}

/// General cart updated state for UI to react to any cart change
class CartChangeSuccess extends CartState {
  final CartEntity cart;

  const CartChangeSuccess({required this.cart});

  @override
  List<Object?> get props => [cart];
}

/// An error occurred while processing a cart operation
class CartOperationFailure extends CartState {
  final String message;
  final CartEntity? lastKnownCart;

  const CartOperationFailure({
    required this.message,
    this.lastKnownCart,
  });

  @override
  List<Object?> get props => [message, lastKnownCart];
}