import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  final SharedPreferences sharedPreferences;
  static const String _localeKey = 'selected_locale';

  LocaleCubit(this.sharedPreferences) : super(const Locale('en')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final String? languageCode = sharedPreferences.getString(_localeKey);
    if (languageCode != null) {
      emit(Locale(languageCode));
    } else {
      // Default to Arabic if no saved locale and we want Arabic as default
      // The user commented "Default to Arabic" in previous version but code was Locale('en')
      // I'll stick to 'en' as default unless 'ar' was intended.
      emit(const Locale('en'));
    }
  }

  Future<void> setLocale(Locale locale) async {
    await sharedPreferences.setString(_localeKey, locale.languageCode);
    emit(locale);
  }

  Future<void> toggleLocale() async {
    if (state.languageCode == 'ar') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('ar'));
    }
  }
}
