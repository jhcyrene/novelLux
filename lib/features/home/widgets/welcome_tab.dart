import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class WelcomeTab extends StatelessWidget {
  const WelcomeTab({
    super.key,
    required this.totalBooks,
    this.readerName = 'Reader',
  });

  final int totalBooks;
  final String readerName;

  String _greetingFor(DateTime time) {
    if (time.hour < 12) {
      return 'Good morning';
    }

    if (time.hour < 18) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final greeting = _greetingFor(DateTime.now());
    final bookLabel = totalBooks == 1 ? 'book' : 'books';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF2B2418), Color(0xFF1A1A1A)]
              : const [Color(0xFFFFF3DB), Color(0xFFF8E4BC)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/main_logo.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $readerName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.sectionHeading(context, fontSize: 18),
                ),
                const SizedBox(height: 3),
                Text(
                  totalBooks == 0
                      ? 'Add a book and begin your next story.'
                      : '$totalBooks $bookLabel ready in your library.',
                  style: AppFonts.body(context, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
