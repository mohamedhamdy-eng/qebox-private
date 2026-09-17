import 'package:flutter/material.dart';

import '../../../core/theme/qebox_theme.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
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
              child: Icon(
                icon,
                size: 28,
                color: QeboxPalette.green,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
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
