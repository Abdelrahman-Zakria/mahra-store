// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MAHRA EG';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get discoverProducts => 'Discover Products';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get viewCart => 'View Cart';

  @override
  String get items => 'Items';

  @override
  String get details => 'Details';

  @override
  String get addToCart => 'ADD TO CART';

  @override
  String addedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String get shoppingCart => 'Shopping Cart';

  @override
  String get yourCartIsEmpty => 'Your cart is empty';

  @override
  String get startShopping => 'Start Shopping';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get shipping => 'Shipping';

  @override
  String get total => 'Total';

  @override
  String get proceedToCheckout => 'PROCEED TO CHECKOUT';

  @override
  String get freeShippingPromo => 'Free shipping for a limited time!';

  @override
  String get checkout => 'Checkout';

  @override
  String get shippingInformation => 'Shipping Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get shippingLocation => 'Shipping Location';

  @override
  String get detailedAddress => 'Detailed Address (Street, Building, Flat)';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cod => 'Cash on Delivery (COD)';

  @override
  String get instapay => 'Instapay';

  @override
  String get instapayInstructions =>
      'Click below to pay via InstaPay, then upload the screenshot here.';

  @override
  String get payViaInstapay => 'PAY VIA INSTAPAY';

  @override
  String get pleaseInsertPaymentImage => 'Please insert payment image';

  @override
  String get paymentImageRequired => 'Payment image is required';

  @override
  String get confirmOrder => 'CONFIRM ORDER';

  @override
  String get orderSuccessful => 'Order Successful';

  @override
  String orderSentSuccess(String orderId) {
    return 'Your order #$orderId has been sent successfully.';
  }

  @override
  String get ok => 'OK';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get revenue => 'Revenue';

  @override
  String get orders => 'Orders';

  @override
  String get freeShipping => 'Free Shipping';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get revenueTrend => 'Revenue Trend';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get viewAll => 'View All';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get productManagement => 'Product Management';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get name => 'Name';

  @override
  String get salePrice => 'Sale Price';

  @override
  String get originalPrice => 'Original Price';

  @override
  String get description => 'Description';

  @override
  String get stock => 'Stock';

  @override
  String get category => 'Category';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get imageIsRequired => 'Image is required';

  @override
  String get pleaseSelectImage => 'Please select an image';

  @override
  String get fillAllFields => 'Please fill all required fields';
}
