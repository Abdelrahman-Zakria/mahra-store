import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final String id;
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity];
}

class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final bool isFreeShipping;
  final double manualShippingCost;

  const CartEntity({
    this.items = const [],
    this.isFreeShipping = false,
    this.manualShippingCost = 0.0,
  });

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shipping {
    if (items.isEmpty) return 0.0;
    if (isFreeShipping) return 0.0;
    return manualShippingCost;
  }

  double get tax => 0.0; // No taxes/VAT

  double get total => subtotal + shipping + tax;

  int get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasItem => items.isNotEmpty;

  bool containsProduct(String productId) =>
      items.any((item) => item.product.id == productId);

  CartItemEntity? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  CartEntity copyWith({
    List<CartItemEntity>? items,
    bool? isFreeShipping,
    double? manualShippingCost,
  }) {
    return CartEntity(
      items: items ?? this.items,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
      manualShippingCost: manualShippingCost ?? this.manualShippingCost,
    );
  }

  @override
  List<Object?> get props => [items, isFreeShipping, manualShippingCost];
}