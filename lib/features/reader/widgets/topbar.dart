import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';

class ReaderTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ReaderTopBar({
    super.key,
    required this.bookTitle,
    required this.onBack,
    required this.onBookmark,
    required this.onMore,
    this.chapterTitle,
    this.isBookmarked = false,
  });

  final String bookTitle;
  final String? chapterTitle;
  final bool isBookmarked;
  final VoidCallback onBack;
  final VoidCallback onBookmark;
  final VoidCallback onMore;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        tooltip: 'Close reader',
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            bookTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.bookTitle(context, fontSize: 15),
          ),
          if (chapterTitle != null)
            Text(
              chapterTitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.metadata(context, fontSize: 11),
            ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
          onPressed: onBookmark,
          icon: Icon(
            isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
          ),
        ),
        IconButton(
          tooltip: 'More actions',
          onPressed: onMore,
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
