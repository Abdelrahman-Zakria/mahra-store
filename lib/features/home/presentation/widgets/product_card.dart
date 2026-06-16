import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatefulWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -12.0 : 0.0)
          ..scale(_isHovered ? 1.02 : 1.0),
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _isHovered 
                      ? Colors.white.withValues(alpha: 0.9) 
                      : Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(
                    color: _isHovered 
                        ? AppColors.gold.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered 
                          ? AppColors.charcoal.withValues(alpha: 0.2) 
                          : AppColors.charcoal.withValues(alpha: 0.08),
                      blurRadius: _isHovered ? 40 : 20,
                      offset: Offset(0, _isHovered ? 20 : 10),
                      spreadRadius: _isHovered ? 4 : -2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image & Badge
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => context.pushProductDetails(widget.product),
                        child: Hero(
                          tag: 'product_image_${widget.product.id}',
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.slateBackground.withValues(alpha: 0.3),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(AppDimens.radiusMd),
                                  ),
                                  image: DecorationImage(
                                    image: widget.product.imagePath.startsWith('http')
                                        ? NetworkImage(widget.product.imagePath)
                                        : AssetImage(widget.product.imagePath) as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (widget.product.isNew)
                                Positioned(
                                  top: AppDimens.sm,
                                  left: AppDimens.sm,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.sm,
                                      vertical: AppDimens.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Product Info
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md,
                          vertical: AppDimens.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontSize: 14,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.product.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.slate.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.product.hasDiscount)
                                        Text(
                                          '${widget.product.originalPrice!.toStringAsFixed(0)} EGP',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            decoration: TextDecoration.lineThrough,
                                            fontSize: 10,
                                          ),
                                        ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${widget.product.price.toStringAsFixed(0)} EGP',
                                          style: AppTextStyles.priceStyle.copyWith(
                                            fontSize: 16,
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => context.read<CartCubit>().addToCart(widget.product),
                                    borderRadius: BorderRadius.circular(AppDimens.radiusCircle),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isHovered ? AppColors.charcoal : AppColors.charcoal.withValues(alpha: 0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_shopping_cart_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
