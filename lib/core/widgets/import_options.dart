import 'package:flutter/material.dart';

import '../theme/app_font.dart';
import '../theme/app_theme.dart';

class ImportOptions extends StatelessWidget {
  const ImportOptions({
    super.key,
    required this.onImportEpub,
    required this.onLinkFolder,
  });

  final VoidCallback onImportEpub;
  final VoidCallback onLinkFolder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Text(
                'Add books',
                style: AppFonts.sectionHeading(context, fontSize: 18),
              ),
            ),
            _ImportOptionTile(
              icon: Icons.book_outlined,
              title: 'Import a novel',
              subtitle: 'Choose EPUB, HTML, or TXT files from your device',
              onTap: onImportEpub,
            ),
            const SizedBox(height: 8),
            _ImportOptionTile(
              icon: Icons.folder_open_outlined,
              title: 'Link a novel folder',
              subtitle: 'Use this folder as your book library storage',
              onTap: onLinkFolder,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportOptionTile extends StatelessWidget {
  const _ImportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppFonts.button(context, fontSize: 14)),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppFonts.metadata(context, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
