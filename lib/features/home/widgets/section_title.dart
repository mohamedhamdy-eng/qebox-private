import 'package:flutter/material.dart';

import '../../../core/theme/qebox_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: QeboxPalette.ink,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: QeboxPalette.orange,
            ),
          ),
        ),
      ],
    );
  }
}
