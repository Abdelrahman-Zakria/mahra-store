import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../home/domain/entities/product_entity.dart';

class ProductDetailsPage extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const BackButton(color: AppColors.charcoal),
          ),
        ),
        actions: [
          const _CartBadge(),
          const SizedBox(width: AppDimens.md),
        ],
      ),
      bottomNavigationBar: isDesktop 
          ? null 
          : _BottomAction(product: product),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop 
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _ProductImage(product: product),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: _ProductInfo(product: product),
                          ),
                        ),
                        _BottomAction(product: product),
                      ],
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductImage(product: product),
                    _ProductInfo(product: product),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final ProductEntity product;
  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    return Hero(
      tag: 'product_image_${product.id}',
      child: Container(
        height: isDesktop ? double.infinity : 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.slateBackground,
          image: DecorationImage(
            image: product.imagePath.startsWith('http')
                ? NetworkImage(product.imagePath)
                : AssetImage(product.imagePath) as ImageProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final ProductEntity product;
  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.category.toUpperCase(), style: AppTextStyles.bodySmall),
            const SizedBox(height: AppDimens.sm),
            Text(product.name, style: AppTextStyles.displayMedium),
            const SizedBox(height: AppDimens.md),
            Row(
              children: [
                Text('${product.price} EGP', style: AppTextStyles.priceStyle.copyWith(fontSize: 24)),
                if (product.hasDiscount) ...[
                  const SizedBox(width: 12),
                  Text(
                    '${product.originalPrice} EGP',
                    style: AppTextStyles.bodyMedium.copyWith(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 18,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            Text(AppLocalizations.of(context)!.description, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppDimens.sm),
            Text(product.description, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final ProductEntity product;
  const _BottomAction({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final quantity = context.read<CartCubit>().getQuantity(product.id);
        final isInCart = quantity > 0;
        
        return Container(
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: isInCart 
            ? Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.slateBackground,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppColors.charcoal),
                            onPressed: () => context.read<CartCubit>().decrementQuantity(product.id),
                          ),
                          Text(
                            '$quantity',
                            style: AppTextStyles.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.charcoal),
                            onPressed: () => context.read<CartCubit>().incrementQuantity(product.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  ElevatedButton(
                    onPressed: () => context.pushCart(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      minimumSize: const Size(120, 50),
                    ),
                    child: Text(l10n.viewCart),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () {
                  context.read<CartCubit>().addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.addedToCart(product.name))),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.charcoal,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 20),
                    const SizedBox(width: AppDimens.sm),
                    Text(l10n.addToCart),
                  ],
                ),
              ),
        );
      },
    );
  }
}

class _CartBadge extends StatelessWidget {
  const _CartBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final count = context.read<CartCubit>().currentCart.totalItemCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.charcoal),
                onPressed: () => context.pushCart(),
              ),
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
