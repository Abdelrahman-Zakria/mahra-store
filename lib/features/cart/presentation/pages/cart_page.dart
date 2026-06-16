import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.sizeOf(context).width > 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const BackButton(color: AppColors.charcoal),
          ),
        ),
        title: Text(l10n.shoppingCart, style: AppTextStyles.headlineLarge),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final cart = context.read<CartCubit>().currentCart;

          if (!cart.hasItem) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.slateLighter),
                  const SizedBox(height: AppDimens.md),
                  Text(l10n.yourCartIsEmpty, style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppDimens.sm),
                  TextButton(
                    onPressed: () => context.goToHome(),
                    child: Text(l10n.startShopping),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.slateBackground.withOpacity(0.5),
                  AppColors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _CartItemsList(cart: cart),
                            ),
                            Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(AppDimens.lg),
                                child: _CartSummaryCard(cart: cart),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: _CartItemsList(cart: cart),
                            ),
                            _CartSummaryCard(cart: cart, isMobile: true),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CartItemsList extends StatelessWidget {
  final CartEntity cart;
  const _CartItemsList({required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimens.md),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimens.md),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _CartItemCard(item: item);
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              color: AppColors.slateBackground,
              child: item.product.imagePath.startsWith('http')
                  ? Image.network(
                      item.product.imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      item.product.imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: AppTextStyles.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      onPressed: () => cubit.removeFromCart(item.product.id),
                    ),
                  ],
                ),
                Text(
                  item.product.category,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppDimens.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.product.price.toStringAsFixed(0)} EGP',
                      style: AppTextStyles.priceStyle.copyWith(color: AppColors.gold),
                    ),
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.slateBackground,
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      child: Row(
                        children: [
                          _QtyActionBtn(
                            icon: Icons.remove,
                            onTap: () => cubit.decrementQuantity(item.product.id),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.titleMedium,
                            ),
                          ),
                          _QtyActionBtn(
                            icon: Icons.add,
                            onTap: () => cubit.incrementQuantity(item.product.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 16, color: AppColors.charcoal),
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  final CartEntity cart;
  final bool isMobile;
  const _CartSummaryCard({required this.cart, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: isMobile 
            ? const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl))
            : BorderRadius.circular(AppDimens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: isMobile ? null : Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: l10n.subtotal, value: cart.subtotal),
          const SizedBox(height: AppDimens.sm),
          _SummaryRow(label: l10n.shipping, value: cart.shipping),
          if (cart.shipping == 0)
            Padding(
              padding: const EdgeInsets.only(top: AppDimens.sm),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.sm),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Text(
                        l10n.freeShippingPromo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.md),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.total, style: AppTextStyles.headlineMedium),
              Text(
                '${cart.total.toStringAsFixed(2)} EGP',
                style: AppTextStyles.priceStyle.copyWith(fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () => context.pushCheckout(),
              child: Text(l10n.proceedToCheckout),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          '${value.toStringAsFixed(2)} EGP',
          style: AppTextStyles.titleMedium,
        ),
      ],
    );
  }
}
