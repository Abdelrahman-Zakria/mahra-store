import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final CheckoutRepository _repository;

  CheckoutCubit(this._repository) : super(CheckoutInitial());

  Future<void> placeOrder({
    required CartEntity cart,
    required String fullName,
    required String address,
    required String phone,
    required String paymentMethod,
    Uint8List? paymentImageBytes,
    String? paymentImageExt,
  }) async {
    emit(CheckoutLoading());
    
    final result = await _repository.placeOrder(
      cart: cart,
      fullName: fullName,
      address: address,
      phone: phone,
      paymentMethod: paymentMethod,
      paymentImageBytes: paymentImageBytes,
      paymentImageExt: paymentImageExt,
    );

    result.fold(
      (error) => emit(CheckoutError(error)),
      (orderId) => emit(CheckoutSuccess(orderId)),
    );
  }
}
