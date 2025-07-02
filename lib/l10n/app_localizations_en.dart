// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Multi-Language Translator';

  @override
  String get menu => 'Menu';

  @override
  String get dictionary => 'Dictionary';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get aboutText => 'This translator was made with ❤️ by Aryan.';

  @override
  String get close => 'Close';

  @override
  String get enterWord => 'Enter a word';

  @override
  String get translate => 'Translate';

  @override
  String get theme => 'Theme';

  @override
  String get systemDefault => 'System Default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get fontSize => 'Font Size';

  @override
  String get languagePreference => 'Language Preference';
}
