import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    super.items,
    super.fullName,
    super.address,
    super.phone,
    super.paymentMethod,
    super.paymentImageUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? itemsJson = json['order_items'];
    List<OrderItemEntity> items = [];
    
    if (itemsJson != null) {
      items = itemsJson.map((item) {
        final product = item['products'];
        return OrderItemEntity(
          id: item['id'] as String? ?? '',
          orderId: item['order_id'] as String? ?? '',
          productId: item['product_id'] as String? ?? '',
          productName: product != null ? product['name'] as String? ?? 'Unknown' : 'Unknown',
          quantity: item['quantity'] as int? ?? 0,
          priceAtPurchase: (item['price_at_purchase'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    }

    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? 'guest',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      items: items,
      fullName: json['full_name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      paymentMethod: json['payment_method'] as String?,
      paymentImageUrl: json['payment_image_url'] as String?,
    );
  }

  @override
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'total_amount': totalAmount,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'full_name': fullName,
    'address': address,
    'phone': phone,
    'payment_method': paymentMethod,
    'payment_image_url': paymentImageUrl,
  };
}
