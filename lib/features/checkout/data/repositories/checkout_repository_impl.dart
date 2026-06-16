import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../../cart/domain/entities/cart_entity.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final SupabaseClient supabase;

  CheckoutRepositoryImpl(this.supabase);

  @override
  Future<Either<String, String>> placeOrder({
    required CartEntity cart,
    required String fullName,
    required String address,
    required String phone,
    required String paymentMethod,
    Uint8List? paymentImageBytes,
    String? paymentImageExt,
  }) async {
    try {
      String? imageUrl;

      // 1. Upload payment image if exists
      if (paymentImageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${paymentImageExt ?? "image.png"}';
        
        await supabase.storage
            .from('payment_proofs')
            .uploadBinary(
              fileName, 
              paymentImageBytes,
              fileOptions: const FileOptions(
                contentType: 'image/png', // Explicitly set for Web compatibility
                upsert: true,
              ),
            );

        imageUrl = supabase.storage
            .from('payment_proofs')
            .getPublicUrl(fileName);
      }

      // 2. Create order with all details
      final orderResponse = await supabase.from('orders').insert({
        'total_amount': cart.total,
        'status': 'pending',
        'full_name': fullName,
        'address': address,
        'phone': phone,
        'payment_method': paymentMethod,
        'payment_image_url': imageUrl,
      }).select().single();

      final orderId = orderResponse['id'] as String;

      // 2. Create order items
      final List<Map<String, dynamic>> itemsData = cart.items.map((item) => {
        'order_id': orderId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price_at_purchase': item.product.price,
      }).toList();

      await supabase.from('order_items').insert(itemsData);

      // Note: We don't decrement stock here because the requirement is 
      // to do it when the admin confirms the order.

      return Right(orderId);
    } catch (e) {
      return Left('Failed to place order: ${e.toString()}');
    }
  }
}
