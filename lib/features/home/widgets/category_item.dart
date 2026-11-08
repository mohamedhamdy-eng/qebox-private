import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/qebox_theme.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? imageUrl;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: QeboxPalette.mint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white),
              ),
              clipBehavior: Clip.antiAlias,
              child: _CategoryImage(imageUrl: imageUrl, icon: icon),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF171717),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.imageUrl, required this.icon});

  final String? imageUrl;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final source = imageUrl;
    if (source == null || source.isEmpty) {
      return Icon(icon, size: 28, color: QeboxPalette.green);
    }
    if (source.startsWith('data:image')) {
      try {
        return Image.memory(
          base64Decode(source.substring(source.indexOf(',') + 1)),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) =>
              Icon(icon, size: 28, color: QeboxPalette.green),
        );
      } catch (_) {
        return Icon(icon, size: 28, color: QeboxPalette.green);
      }
    }
    return Image.network(
      source,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) =>
          Icon(icon, size: 28, color: QeboxPalette.green),
    );
  }
}
