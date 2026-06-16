import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../cart/domain/entities/cart_entity.dart';

abstract class CheckoutRepository {
  Future<Either<String, String>> placeOrder({
    required CartEntity cart,
    required String fullName,
    required String address,
    required String phone,
    required String paymentMethod,
    Uint8List? paymentImageBytes,
    String? paymentImageExt,
  });
}
