import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class LibraryShortcutSection extends StatelessWidget {
  const LibraryShortcutSection({
    super.key,
    required this.totalBooks,
    required this.favoriteCount,
    required this.bookmarkCount,
    required this.recentCount,
    required this.onViewAll,
    required this.onAllBooks,
    required this.onFavorites,
    required this.onBookmarks,
    required this.onRecent,
  });

  final int totalBooks;
  final int favoriteCount;
  final int bookmarkCount;
  final int recentCount;

  final VoidCallback onViewAll;
  final VoidCallback onAllBooks;
  final VoidCallback onFavorites;
  final VoidCallback onBookmarks;
  final VoidCallback onRecent;
  static const double cardHeight = 100;
  static const double iconSize = 20;
  static const double verticalPadding = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'My Library',
                style: AppFonts.sectionHeading(
                  context,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gold,
                padding: EdgeInsets.zero,
                minimumSize: const Size(55, 32),
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: AppFonts.button(
                  context,
                  fontSize: 12,
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _LibraryShortcutCard(
                icon: Icons.local_library_outlined,
                label: 'All Books',
                count: totalBooks,
                onTap: onAllBooks,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LibraryShortcutCard(
                icon: Icons.favorite_border,
                label: 'Favorites',
                count: favoriteCount,
                onTap: onFavorites,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LibraryShortcutCard(
                icon: Icons.bookmark_border,
                label: 'Bookmarks',
                count: bookmarkCount,
                onTap: onBookmarks,
                
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LibraryShortcutCard(
                icon: Icons.access_time,
                label: 'Recent',
                count: recentCount,
                onTap: onRecent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LibraryShortcutCard extends StatelessWidget {
  const _LibraryShortcutCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
    
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: LibraryShortcutSection.cardHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.gold.withValues(
                alpha: 0.16,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 25.0,
                color: AppColors.gold,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.metadata(
                  context,
                  fontSize: 11,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: AppFonts.metadata(
                  context,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}