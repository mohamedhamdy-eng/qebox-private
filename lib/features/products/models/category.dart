import '../../../core/l10n/app_language.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.nameAr,
    required this.isActive,
    this.imageUrl,
    this.sortOrder = 0,
  });
  final String id;
  final String name;
  final String? nameAr;

  String get displayName =>
      AppLanguage.isArabic && (nameAr?.isNotEmpty ?? false) ? nameAr! : name;
  final bool isActive;
  final String? imageUrl;
  final int sortOrder;
}
