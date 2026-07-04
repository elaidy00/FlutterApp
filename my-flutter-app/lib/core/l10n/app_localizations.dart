import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  String get welcomeBack => locale.languageCode == 'ar' ? 'مرحبًا بعودتك' : 'Welcome back';

  String get signIn => locale.languageCode == 'ar' ? 'تسجيل الدخول' : 'Sign in';

  String get createAccount => locale.languageCode == 'ar' ? 'إنشاء حساب' : 'Create account';

  String get choosePath => locale.languageCode == 'ar' ? 'اختر مسارك' : 'Choose your path';

  String get student => locale.languageCode == 'ar' ? 'طالب' : 'Student';

  String get instructor => locale.languageCode == 'ar' ? 'مدرب' : 'Instructor';

  String get recommendedCourses =>
      locale.languageCode == 'ar' ? 'الدورات المقترحة' : 'Recommended courses';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.contains(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
