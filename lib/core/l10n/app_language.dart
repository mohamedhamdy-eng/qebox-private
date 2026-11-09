import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translations_ar.dart';

const supportedAppLocales = [Locale('en'), Locale('ar')];

abstract final class AppLanguage {
  /// [LanguageScope] sets this value before the screens rebuild.
  static bool isArabic = false;
}

String translate(String english, List<Object?> args, {required bool arabic}) {
  var text = arabic ? (arabicTranslations[english] ?? english) : english;
  for (var index = 0; index < args.length; index++) {
    text = text.replaceAll('{$index}', '${args[index]}');
  }
  return text;
}

/// Returns the text in the current app language. The English text is the key.
String tr(String english, [List<Object?> args = const []]) =>
    translate(english, args, arabic: AppLanguage.isArabic);

/// Holds the language that the customer chose. Null means the device language.
class LanguageViewModel extends StateNotifier<Locale?> {
  LanguageViewModel(this._preferences) : super(_load(_preferences));

  static const _key = 'app_language';
  final SharedPreferences _preferences;

  static Locale? _load(SharedPreferences preferences) {
    final code = preferences.getString(_key);
    return code == null ? null : Locale(code);
  }

  void select(Locale? locale) {
    state = locale;
    if (locale == null) {
      _preferences.remove(_key);
    } else {
      _preferences.setString(_key, locale.languageCode);
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageViewModel, Locale?>(
  (ref) => throw UnimplementedError(
    'languageProvider must be overridden with preferences in main.',
  ),
);

/// Applies the app locale to [tr] and refreshes open screens when it changes.
class LanguageScope extends StatefulWidget {
  const LanguageScope({required this.child, super.key});

  final Widget child;

  @override
  State<LanguageScope> createState() => _LanguageScopeState();
}

class _LanguageScopeState extends State<LanguageScope> {
  bool? _appliedArabic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final changed = _appliedArabic != null && _appliedArabic != arabic;
    _appliedArabic = arabic;
    AppLanguage.isArabic = arabic;
    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildScreens());
    }
  }

  // Screens read the language through tr, which has no widget dependency.
  void _rebuildScreens() {
    if (!mounted) return;
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
