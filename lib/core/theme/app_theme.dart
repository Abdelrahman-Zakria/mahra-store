import 'package:flutter/material.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Primary
  static const charcoal = Color(0xFF2C2C2C);
  static const charcoalLight = Color(0xFF3E3E3E);
  static const charcoalDark = Color(0xFF1A1A1A);

  // Secondary (Slate)
  static const slate = Color(0xFF64748B);
  static const slateLight = Color(0xFF94A3B8);
  static const slateLighter = Color(0xFFCBD5E1);
  static const slateBackground = Color(0xFFF1F5F9);

  // Accent
  static const gold = Color(0xFFD4A853);
  static const goldLight = Color(0xFFF0C675);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Surface
  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLayer = Color(0xFFF1F5F9);
  static const divider = Color(0xFFE2E8F0);
  static const shadow = Color(0x1A000000);
  static const glassBase = Color(0xCCFFFFFF);
}

// ─── Text Styles ─────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const _baseFamily = 'Poppins';

  static const displayLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const headlineLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
    height: 1.4,
  );

  static const titleLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
    height: 1.5,
  );

  static const titleMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.charcoal,
    height: 1.5,
  );

  static const bodyLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.charcoal,
    height: 1.6,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.slate,
    height: 1.6,
  );

  static const bodySmall = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.slateLight,
    height: 1.5,
  );

  static const labelLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  static const priceStyle = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    letterSpacing: -0.3,
  );

  static const priceSmall = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
  );
}

// ─── Dimensions ──────────────────────────────────────────────────────────────
class AppDimens {
  AppDimens._();

  // Spacing (8px grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusCircle = 100.0;

  // Icon sizes
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Component sizes
  static const double appBarHeight = 60.0;
  static const double productCardHeight = 260.0;
  static const double categoryCircleSize = 64.0;
  static const double bannerHeight = 180.0;
  static const double bottomNavHeight = 72.0;
}

// ─── Theme ───────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.charcoal,
      primary: AppColors.charcoal,
      secondary: AppColors.slate,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineLarge,
      iconTheme: IconThemeData(color: AppColors.charcoal, size: AppDimens.iconMd),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      },
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.slateBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide.none,
      ),
      hintStyle: AppTextStyles.bodyMedium,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm + AppDimens.xs,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
    fontFamily: 'Poppins',
  );
}