import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/app_router.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'core/cubit/locale_cubit.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // TODO: Replace with your Supabase credentials
  await Supabase.initialize(
    url: 'https://zahvsvhaswbelnfosbzw.supabase.co',
    anonKey: 'sb_publishable_wwOGsZjvS87GaMyvoFE-8Q_DatBA-7R',

  );

  // Initialize Dependency Injection
  await di.configureDependencies();

  // Run Seeder once (Optional: uncomment to seed data)
    //await Seeder.seed();

  runApp(const MahraStore());
}

class MahraStore extends StatelessWidget {
  const MahraStore({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>(create: (_) => di.getIt<CartCubit>()),
        BlocProvider<LocaleCubit>(create: (_) => di.getIt<LocaleCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'MAHRA EG',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            locale: locale,
          );
        },
      ),
    );
  }
}