import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/admin/presentation/cubit/admin_cubit.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_login_screen.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/checkout/presentation/cubit/checkout_cubit.dart';
import '../features/checkout/presentation/pages/checkout_page.dart';
import '../features/home/domain/entities/product_entity.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/product_details/presentation/pages/product_details_page.dart';
import 'di/injection_container.dart';

class AppRoutes {
  static const home = '/';
  static const productDetails = '/product/:id';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const adminLogin = '/admin';
  static const adminDashboard = '/admin/dashboard';
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.adminLogin,
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'admin-dashboard',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<AdminCubit>(),
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        name: 'product-details',
        builder: (context, state) {
          final product = state.extra as ProductEntity;
          return ProductDetailsPage(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<CheckoutCubit>(),
          child: const CheckoutPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
}

// ─── Navigation Extension ─────────────────────────────────────────────────────
extension AppNavigation on BuildContext {
  void goToHome() => go(AppRoutes.home);

  void goToProductDetails(ProductEntity product) {
    go('/product/${product.id}', extra: product);
  }

  void goToCart() => go(AppRoutes.cart);

  void goToCheckout() => go(AppRoutes.checkout);

  void pushProductDetails(ProductEntity product) {
    push('/product/${product.id}', extra: product);
  }

  void pushCart() => push(AppRoutes.cart);

  void pushCheckout() => push(AppRoutes.checkout);

  void goToAdmin() => go(AppRoutes.adminLogin);

  void pushAdmin() => push(AppRoutes.adminLogin);
}
