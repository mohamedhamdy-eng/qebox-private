import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qebox_private/core/l10n/app_language.dart';
import 'package:qebox_private/core/l10n/translations_ar.dart';

void main() {
  tearDown(() => AppLanguage.isArabic = false);

  test('returns English by default and fills values', () {
    expect(tr('EGP {0}', ['65.00']), 'EGP 65.00');
  });

  test('returns Arabic and fills values', () {
    AppLanguage.isArabic = true;

    expect(tr('EGP {0}', ['65.00']), '65.00 ج.م');
    expect(tr('You can order up to {0} of {1}.', [2, 'لبن']), contains('لبن'));
  });

  test('falls back to English for unknown text', () {
    AppLanguage.isArabic = true;

    expect(tr('Unknown text'), 'Unknown text');
  });

  test('every translated string in the app has Arabic text', () {
    final pattern = RegExp(r"\b(?:tr|_t)\(\s*'((?:[^'\\]|\\.)*)'");
    final missing = <String>[];
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in sources) {
      for (final match in pattern.allMatches(file.readAsStringSync())) {
        final key = match
            .group(1)!
            .replaceAll(r"\'", "'")
            .replaceAll(r'\n', '\n');
        if (!arabicTranslations.containsKey(key)) missing.add(key);
      }
    }

    expect(missing, isEmpty);
  });

  test('every Arabic text keeps the markers of its English text', () {
    final marker = RegExp(r'\{\d+\}');
    arabicTranslations.forEach((english, arabic) {
      final expected = marker.allMatches(english).map((m) => m[0]).toSet();
      final actual = marker.allMatches(arabic).map((m) => m[0]).toSet();
      expect(actual, expected, reason: english);
    });
  });
}
