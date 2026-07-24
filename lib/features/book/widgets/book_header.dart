import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';

class BookHeader extends StatelessWidget implements PreferredSizeWidget {
  const BookHeader({
    super.key,
    this.title = 'Book Details',
    this.isBookmarked = false,
    this.onBackPressed,
    this.onBookmarkPressed,
    this.onMorePressed,
  });

  final String title;
  final bool isBookmarked;
  final VoidCallback? onBackPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onMorePressed;

  static const double height = 56;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: height,
      leadingWidth: 44,
      leading: IconButton(
        tooltip: 'Back',
        onPressed: onBackPressed ?? () => Navigator.maybePop(context),
        icon: const Icon(Icons.chevron_left_rounded, size: 22),
      ),
      title: Text(
        title,
        style: AppFonts.pageTitle(
          context,
          fontSize: 20,
          color: colors.onSurface,
        ).copyWith(fontWeight: FontWeight.w500),
      ),
      actions: [
        IconButton(
          tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
          onPressed: onBookmarkPressed ?? () {},
          icon: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            size: 20,
          ),
        ),
        IconButton(
          tooltip: 'More options',
          onPressed: onMorePressed ?? () {},
          icon: const Icon(Icons.more_vert_rounded, size: 20),
        ),
        const SizedBox(width: 2),
      ],
    );
  }
}
