import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/app_router.dart';
import '../../../../core/cubit/locale_cubit.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch(BuildContext context) {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<HomeCubit>().searchProducts('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadHomeData(),
      child: Builder(builder: (context) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(AppDimens.appBarHeight),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  backgroundColor: AppColors.glassBase.withValues(alpha: 0.1),
                  elevation: 0,
                  title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchProducts,
                      border: InputBorder.none,
                      filled: false,
                    ),
                    style: AppTextStyles.titleLarge,
                    onChanged: (value) {
                      context.read<HomeCubit>().searchProducts(value);
                    },
                  )
                : Row(
                    children: [
                      Image.asset(
                        "assets/logo/logo_no_bg.png",
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      Text(l10n.appTitle, style: const TextStyle(color: AppColors.charcoal, fontWeight: FontWeight.bold)),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () => context.read<LocaleCubit>().toggleLocale(),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? 'EN' : 'عربي',
                  style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: AppColors.charcoal,
                ),
                onPressed: () => _toggleSearch(context),
              ),
              if (!_isSearching) ...[
                const _CartBadge(),
                const SizedBox(width: AppDimens.sm),
              ],
            ],
          ),
        ),
      ),
    ),
          body: Stack(
            children: [
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    );
                  } else if (state is HomeLoadSuccess) {
                    return RefreshIndicator(
                      onRefresh: () => context.read<HomeCubit>().refresh(),
                      color: AppColors.gold,
                      child: CustomScrollView(
                        slivers: [
                          // Add space for the transparent AppBar
                          const SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.appBarHeight + AppDimens.md),
                          ),

                          // Categories Horizontal Slider
                          if (!_isSearching)
                            SliverToBoxAdapter(
                              child: _CategoryList(
                                categories: state.categories,
                                selectedId: state.selectedCategoryId,
                              ),
                            ),

                          // Featured Banner Section
                          if (state.banners.isNotEmpty && !_isSearching)
                            SliverToBoxAdapter(
                              child: _BannerSlider(banners: state.banners),
                            ),

                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimens.md,
                              AppDimens.lg,
                              AppDimens.md,
                              AppDimens.sm,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                _isSearching ? l10n.searchResults : l10n.discoverProducts,
                                style: AppTextStyles.headlineMedium,
                              ),
                            ),
                          ),

                          // Products Grid
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                            sliver: state.filteredProducts.isEmpty
                                ? SliverToBoxAdapter(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 40),
                                        child: Text(l10n.noProductsFound),
                                      ),
                                    ),
                                  )
                                : SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: MediaQuery.sizeOf(context).width > 800 ? 4 : 2,
                                      mainAxisSpacing: AppDimens.md,
                                      crossAxisSpacing: AppDimens.md,
                                      childAspectRatio: MediaQuery.sizeOf(context).width > 800 ? 1.0 : 0.65,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        return TweenAnimationBuilder<double>(
                                          duration: Duration(milliseconds: 400 + (index * 50)),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, value, child) {
                                            return Transform.translate(
                                              offset: Offset(0, 30 * (1 - value)),
                                              child: Opacity(
                                                opacity: value,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: ProductCard(
                                            product: state.filteredProducts[index],
                                          ),
                                        );
                                      },
                                      childCount: state.filteredProducts.length,
                                    ),
                                  ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: AppDimens.xxl)),
                        ],
                      ),
                    );
                  } else if (state is HomeLoadFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: AppDimens.md),
                          Text(state.message),
                          TextButton(
                            onPressed: () => context.read<HomeCubit>().loadHomeData(),
                            child: const Text("Retry"),
                          )
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.md),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const _FloatingCartSummary(),
                  ),
                ),
              ),
              const _WhatsAppFAB(),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

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
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () => context.pushCart(),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
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

class _FloatingCartSummary extends StatelessWidget {
  const _FloatingCartSummary();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cart = context.read<CartCubit>().currentCart;
        if (cart.totalItemCount == 0) return const SizedBox();

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () => context.pushCart(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.lg,
                vertical: AppDimens.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${cart.totalItemCount} ${l10n.items}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${cart.total.toStringAsFixed(2)} EGP',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.viewCart,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppDimens.xs),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.gold,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WhatsAppFAB extends StatelessWidget {
  const _WhatsAppFAB();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final hasCart = context.read<CartCubit>().currentCart.totalItemCount > 0;
        return AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: hasCart ? 120 : AppDimens.lg,
              right: AppDimens.md,
            ),
            child: FloatingActionButton(
            onPressed: () async {
              final Uri url = Uri.parse("https://wa.me/201032592970");
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch WhatsApp')),
                  );
                }
              }
            },
            backgroundColor: const Color(0xFF25D366),
            child: const Icon(Icons.chat, color: Colors.white),
          ),
        ));
      },
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String selectedId;

  const _CategoryList({required this.categories, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.id == selectedId;

            return GestureDetector(
              onTap: () => context.read<HomeCubit>().filterByCategory(category.id),
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimens.lg, top: AppDimens.md),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: AppDimens.categoryCircleSize,
                      width: AppDimens.categoryCircleSize,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.charcoal : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.charcoal : AppColors.divider,
                        ),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        category.icon,
                        color: isSelected ? AppColors.white : AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Text(
                      category.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected ? AppColors.charcoal : AppColors.slate,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BannerSlider extends StatelessWidget {
  final List<BannerEntity> banners;
  const _BannerSlider({required this.banners});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.bannerHeight,
      child: PageView.builder(
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppDimens.md),
            decoration: BoxDecoration(
              color: banner.backgroundColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              image: banner.imagePath != null
                  ? DecorationImage(
                      image: banner.imagePath!.startsWith('http')
                          ? NetworkImage(banner.imagePath!)
                          : AssetImage(banner.imagePath!) as ImageProvider,
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                if (banner.imagePath == null)
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.sm,
                            vertical: AppDimens.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                          ),
                          child: Text(
                            banner.badgeText,
                            style: TextStyle(color: banner.textColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          banner.title,
                          style: AppTextStyles.displayMedium.copyWith(color: banner.textColor),
                        ),
                        Text(
                          banner.subtitle,
                          style: AppTextStyles.bodySmall.copyWith(color: banner.textColor.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
