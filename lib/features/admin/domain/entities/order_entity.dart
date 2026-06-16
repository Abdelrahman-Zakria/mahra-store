import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<OrderItemEntity> items;
  final String? fullName;
  final String? address;
  final String? phone;
  final String? paymentMethod;
  final String? paymentImageUrl;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.items = const [],
    this.fullName,
    this.address,
    this.phone,
    this.paymentMethod,
    this.paymentImageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        totalAmount,
        status,
        createdAt,
        items,
        fullName,
        address,
        phone,
        paymentMethod,
        paymentImageUrl,
      ];

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
