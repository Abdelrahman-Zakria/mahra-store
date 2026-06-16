// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Mahra EG';

  @override
  String get searchProducts => 'البحث عن المنتجات...';

  @override
  String get discoverProducts => 'اكتشف منتجاتنا';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get items => 'منتجات';

  @override
  String get details => 'التفاصيل';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String addedToCart(String productName) {
    return 'تم إضافة $productName إلى السلة';
  }

  @override
  String get shoppingCart => 'سلة التسوق';

  @override
  String get yourCartIsEmpty => 'سلة التسوق فارغة';

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get shipping => 'الشحن';

  @override
  String get total => 'الإجمالي';

  @override
  String get proceedToCheckout => 'إتمام الشراء';

  @override
  String get freeShippingPromo => 'شحن مجاني لفترة محدودة!';

  @override
  String get checkout => 'الدفع';

  @override
  String get shippingInformation => 'معلومات الشحن';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get shippingLocation => 'موقع الشحن';

  @override
  String get detailedAddress => 'العنوان بالتفصيل (الشارع، المبنى، الشقة)';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cod => 'الدفع عند الاستلام';

  @override
  String get instapay => 'إنستا باي';

  @override
  String get instapayInstructions =>
      'اضغط أدناه للدفع عبر إنستا باي، ثم قم برفع لقطة الشاشة هنا.';

  @override
  String get payViaInstapay => 'ادفع عبر إنستا باي';

  @override
  String get pleaseInsertPaymentImage => 'يرجى إدراج صورة الدفع';

  @override
  String get paymentImageRequired => 'صورة الدفع مطلوبة';

  @override
  String get confirmOrder => 'تأكيد الطلب';

  @override
  String get orderSuccessful => 'تم الطلب بنجاح';

  @override
  String orderSentSuccess(String orderId) {
    return 'تم إرسال طلبك رقم $orderId بنجاح.';
  }

  @override
  String get ok => 'موافق';

  @override
  String get adminDashboard => 'لوحة تحكم المسؤول';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get orders => 'الطلبات';

  @override
  String get freeShipping => 'شحن مجاني';

  @override
  String get enabled => 'مفعل';

  @override
  String get disabled => 'معطل';

  @override
  String get revenueTrend => 'اتجاه الإيرادات';

  @override
  String get recentOrders => 'الطلبات الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get manageCategories => 'إدارة الفئات';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get productManagement => 'إدارة المنتجات';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editProduct => 'تعديل منتج';

  @override
  String get name => 'الاسم';

  @override
  String get salePrice => 'سعر البيع';

  @override
  String get originalPrice => 'السعر الأصلي';

  @override
  String get description => 'الوصف';

  @override
  String get stock => 'المخزون';

  @override
  String get category => 'الفئة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get imageIsRequired => 'الصورة مطلوبة';

  @override
  String get pleaseSelectImage => 'يرجى اختيار صورة';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول المطلوبة';
}
