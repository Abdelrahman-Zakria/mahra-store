import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';

enum PaymentMethod { cod, instapay }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedLocation = 'Cairo';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cod;
  XFile? _paymentImage;
  final ImagePicker _picker = ImagePicker();
  final String _instaPayUrl = 'https://ipn.eg/S/abdelrahmanzakria122/instapay/4GKxxj';

  final Map<String, double> _shippingRates = {
    'Cairo': 90.0,
    'Giza': 90.0,
    'Banha': 0.0,
  };

  @override
  void initState() {
    super.initState();
    // Set initial shipping cost
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().updateShippingCost(_shippingRates[_selectedLocation]!);
    });
  }

  Future<void> _launchInstaPay() async {
    final Uri url = Uri.parse(_instaPayUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch InstaPay link')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _paymentImage = pickedFile;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onConfirmOrder() async {
    bool isValid = _formKey.currentState!.validate();
    if (_selectedPaymentMethod == PaymentMethod.instapay && _paymentImage == null) {
      isValid = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please insert payment image')),
      );
      return;
    }

    if (isValid) {
      final cart = context.read<CartCubit>().currentCart;
      
      Uint8List? imageBytes;
      String? imageExt;
      
      if (_paymentImage != null) {
        imageBytes = await _paymentImage!.readAsBytes();
        imageExt = _paymentImage!.name;
      }

      if (!mounted) return;

      context.read<CheckoutCubit>().placeOrder(
        cart: cart,
        fullName: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        paymentMethod: _selectedPaymentMethod == PaymentMethod.cod ? 'cod' : 'instapay',
        paymentImageBytes: imageBytes,
        paymentImageExt: imageExt,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartCubit>().currentCart;
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.sizeOf(context).width > 800;

    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          context.read<CartCubit>().clearCart();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text(l10n.orderSuccessful),
              content: Text(l10n.orderSentSuccess(state.orderId.substring(0, 8))),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goToHome();
                  },
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.checkout)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Form(
              key: _formKey,
              child: isDesktop 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          child: _buildShippingInfo(l10n),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          child: _buildOrderSummaryAndPayment(cart, l10n),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShippingInfo(l10n),
                        const SizedBox(height: AppDimens.xl),
                        _buildOrderSummaryAndPayment(cart, l10n),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShippingInfo(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.shippingInformation, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppDimens.md),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.fullName,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your name';
            return null;
          },
        ),
        const SizedBox(height: AppDimens.md),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phoneNumber,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your phone number';
            return null;
          },
        ),
        const SizedBox(height: AppDimens.md),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: InputDecoration(
            labelText: l10n.shippingLocation,
            border: const OutlineInputBorder(),
          ),
          items: _shippingRates.keys.map((location) {
            return DropdownMenuItem(
              value: location,
              child: Text('$location (${_shippingRates[location]} EGP)'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLocation = value);
              context.read<CartCubit>().updateShippingCost(_shippingRates[value]!);
            }
          },
        ),
        const SizedBox(height: AppDimens.md),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.detailedAddress,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your detailed address';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummaryAndPayment(CartEntity cart, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.orderSummary, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppDimens.md),
        Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              ...cart.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.quantity}x ', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(item.product.name, style: AppTextStyles.bodyMedium, maxLines: 2)),
                        Text('${item.totalPrice.toStringAsFixed(2)} EGP', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  )),
              const Divider(height: AppDimens.lg),
              _SummaryRow(label: l10n.subtotal, value: cart.subtotal),
              const SizedBox(height: AppDimens.xs),
              _SummaryRow(label: l10n.shipping, value: cart.shipping),
              const Divider(height: AppDimens.lg),
              _SummaryRow(label: l10n.total, value: cart.total, isBold: true),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        Text(l10n.paymentMethod, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppDimens.md),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Column(
            children: [
              RadioListTile<PaymentMethod>(
                title: Text(l10n.cod),
                value: PaymentMethod.cod,
                groupValue: _selectedPaymentMethod,
                onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
              ),
              const Divider(height: 1),
              RadioListTile<PaymentMethod>(
                title: Text(l10n.instapay),
                value: PaymentMethod.instapay,
                groupValue: _selectedPaymentMethod,
                onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
              ),
              if (_selectedPaymentMethod == PaymentMethod.instapay)
                Padding(
                  padding: const EdgeInsets.all(AppDimens.md),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _launchInstaPay,
                        icon: const Icon(Icons.payment_rounded, size: 20),
                        label: Text(l10n.payViaInstapay),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.white),
                      ),
                      const SizedBox(height: AppDimens.md),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.charcoal, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          ),
                          child: _paymentImage != null
                              ? Image.network(_paymentImage!.path, fit: BoxFit.cover)
                              : const Icon(Icons.cloud_upload_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state is CheckoutLoading ? null : _onConfirmOrder,
              child: Center(
                child: state is CheckoutLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(l10n.confirmOrder),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium),
        Text('${value.toStringAsFixed(2)} EGP', style: isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium),
      ],
    );
  }
}
