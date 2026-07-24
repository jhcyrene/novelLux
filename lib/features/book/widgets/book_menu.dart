import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class BookMenu extends StatelessWidget {
  const BookMenu({
    super.key,
    required this.onStartReading,
    required this.onFavoritePressed,
    this.isFavorite = false,
  });

  final VoidCallback onStartReading;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

return Column(
      children: [
        _BookMenuButton(
          label: 'Start Reading',
          icon: Icons.menu_book_outlined,
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.deepBlack,
          onPressed: onStartReading,
        ),
        const SizedBox(height: 10),
        _BookMenuButton(
          label: isFavorite ? 'Remove Favorite' : 'Add to Favorites',
          icon: isFavorite
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          backgroundColor: colors.surfaceContainerHighest,
          foregroundColor: colors.onSurface,
          onPressed: onFavoritePressed,
        ),
      ],
    );
  }
}

class _BookMenuButton extends StatelessWidget {
  const _BookMenuButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: AppFonts.button(context, fontSize: 12, color: foregroundColor),
        ),
      ),
    );
  }
}
