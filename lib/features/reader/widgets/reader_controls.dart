import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class ReaderControls extends StatelessWidget {
  const ReaderControls({
    super.key,
    required this.readingProgress,
    required this.onContents,
    required this.onStart,
    required this.onPrevious,
    required this.onNext,
    required this.onEnd,
    required this.onSettings,
  });

  final ValueListenable<double> readingProgress;
  final VoidCallback onContents;
  final VoidCallback? onStart;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onEnd;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Contents',
                onPressed: onContents,
                icon: const Icon(Icons.format_list_bulleted),
              ),
              _ChapterNavigationButton(
                tooltip: 'First chapter',
                label: 'Start',
                icon: Icons.first_page_rounded,
                onPressed: onStart,
              ),
              _ChapterNavigationButton(
                tooltip: 'Previous chapter',
                label: 'Prev',
                icon: Icons.chevron_left_rounded,
                onPressed: onPrevious,
              ),
              ValueListenableBuilder<double>(
                valueListenable: readingProgress,
                builder: (context, progress, child) {
                  final percentage = (progress * 100).round();

                  return Text(
                    '$percentage%',
                    style: AppFonts.metadata(context, color: AppColors.gold),
                  );
                },
              ),
              _ChapterNavigationButton(
                tooltip: 'Next chapter',
                label: 'Next',
                icon: Icons.chevron_right_rounded,
                onPressed: onNext,
              ),
              _ChapterNavigationButton(
                tooltip: 'Last chapter',
                label: 'End',
                icon: Icons.last_page_rounded,
                onPressed: onEnd,
              ),
              IconButton(
                tooltip: 'Reader settings',
                onPressed: onSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterNavigationButton extends StatelessWidget {
  const _ChapterNavigationButton({
    required this.tooltip,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = onPressed == null
        ? colors.onSurface.withValues(alpha: 0.3)
        : colors.onSurface;

    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 28,
        child: SizedBox(
          width: 42,
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 1),
              Text(
                label,
                style: AppFonts.navigationLabel(
                  context,
                  fontSize: 9,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
