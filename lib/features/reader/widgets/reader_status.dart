import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/skeleton_loader.dart';

class ReaderLoadingView extends StatelessWidget {
  const ReaderLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 28, 24, 48),
      child: SkeletonLoader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: SkeletonBox(width: 190, height: 30)),
            SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 1)),
                SizedBox(width: 10),
                SkeletonBox(width: 15, height: 15, borderRadius: 8),
                SizedBox(width: 10),
                Expanded(child: SkeletonBox(height: 1)),
              ],
            ),
            SizedBox(height: 28),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(width: 250, height: 15),
            SizedBox(height: 26),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(width: 285, height: 15),
            SizedBox(height: 26),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(height: 15),
            SizedBox(height: 10),
            SkeletonBox(width: 220, height: 15),
          ],
        ),
      ),
    );
  }
}

class ReaderErrorView extends StatelessWidget {
  const ReaderErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: AppColors.gold,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(context),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class ReaderEmptyView extends StatelessWidget {
  const ReaderEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No chapter available.'));
  }
}
