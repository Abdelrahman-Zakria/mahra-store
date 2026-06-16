import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double priceAtPurchase;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  @override
  List<Object?> get props => [id, orderId, productId, productName, quantity, priceAtPurchase];
}
