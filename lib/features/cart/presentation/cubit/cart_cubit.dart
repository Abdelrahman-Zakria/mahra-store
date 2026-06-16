import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../home/domain/entities/product_entity.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartEntity _cart = const CartEntity();
  final _uuid = const Uuid();
  final SupabaseClient _supabase = Supabase.instance.client;

  CartCubit() : super(const CartInitial()) {
    _initialize();
  }

  void _initialize() {
    _cart = _cart.copyWith(manualShippingCost: 90.0); // Default shipping
    fetchShippingSettings();
    emit(CartChangeSuccess(cart: _cart));
  }

  Future<void> fetchShippingSettings() async {
    try {
      final response = await _supabase
          .from('app_settings')
          .select('value')
          .eq('setting_key', 'free_shipping')
          .maybeSingle();
      
      if (response != null) {
        final isFree = response['value'] as bool;
        _cart = _cart.copyWith(isFreeShipping: isFree);
        emit(CartChangeSuccess(cart: _cart));
      }
    } catch (e) {
      // Silently fail or log
    }
  }

  void updateShippingCost(double cost) {
    _cart = _cart.copyWith(manualShippingCost: cost);
    emit(CartChangeSuccess(cart: _cart));
  }

  /// Gets the current cart (safe getter for reading without state changes)
  CartEntity get currentCart => _cart;

  /// Adds a product to the cart or increments its quantity
  void addToCart(ProductEntity product) {
    try {
      final existingItem = _cart.getItem(product.id);

      List<CartItemEntity> updatedItems;

      if (existingItem != null) {
        // Increment quantity if product already in cart
        updatedItems = _cart.items
            .map((item) => item.product.id == product.id
            ? item.copyWith(quantity: item.quantity + 1)
            : item)
            .toList();
      } else {
        // Add new item to cart
        final newItem = CartItemEntity(
          id: _uuid.v4(),
          product: product,
          quantity: 1,
        );
        updatedItems = [..._cart.items, newItem];
      }

      _cart = _cart.copyWith(items: updatedItems);

      emit(CartItemAddSuccess(
        cart: _cart,
        addedProductId: product.id,
      ));
    } catch (e) {
      emit(CartOperationFailure(
        message: 'Failed to add item to cart',
        lastKnownCart: _cart,
      ));
    }
  }

  /// Removes a product completely from the cart
  void removeFromCart(String productId) {
    try {
      final updatedItems =
      _cart.items.where((item) => item.product.id != productId).toList();
      _cart = _cart.copyWith(items: updatedItems);

      emit(CartItemRemoveSuccess(
        cart: _cart,
        removedProductId: productId,
      ));
    } catch (e) {
      emit(CartOperationFailure(
        message: 'Failed to remove item from cart',
        lastKnownCart: _cart,
      ));
    }
  }

  /// Updates the quantity of a specific cart item
  void updateQuantity(String productId, int quantity) {
    try {
      if (quantity <= 0) {
        removeFromCart(productId);
        return;
      }

      final updatedItems = _cart.items
          .map((item) => item.product.id == productId
          ? item.copyWith(quantity: quantity)
          : item)
          .toList();

      _cart = _cart.copyWith(items: updatedItems);

      emit(CartQuantityChangeSuccess(
        cart: _cart,
        productId: productId,
        newQuantity: quantity,
      ));
    } catch (e) {
      emit(CartOperationFailure(
        message: 'Failed to update quantity',
        lastKnownCart: _cart,
      ));
    }
  }

  /// Increments quantity of an existing cart item
  void incrementQuantity(String productId) {
    final item = _cart.getItem(productId);
    if (item != null) {
      updateQuantity(productId, item.quantity + 1);
    }
  }

  /// Decrements quantity, removing the item if quantity reaches 0
  void decrementQuantity(String productId) {
    final item = _cart.getItem(productId);
    if (item != null) {
      updateQuantity(productId, item.quantity - 1);
    }
  }

  /// Clears all items from the cart
  void clearCart() {
    try {
      _cart = const CartEntity();
      emit(CartClearSuccess(cart: _cart));
    } catch (e) {
      emit(CartOperationFailure(
        message: 'Failed to clear cart',
        lastKnownCart: _cart,
      ));
    }
  }

  /// Checks if a product is in the cart
  bool isInCart(String productId) => _cart.containsProduct(productId);

  /// Gets the quantity of a specific product in the cart
  int getQuantity(String productId) {
    return _cart.getItem(productId)?.quantity ?? 0;
  }
}