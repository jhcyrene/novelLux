import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../../../core/models/book_metadata.dart';
import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class BookSummary extends StatefulWidget {
  const BookSummary({
    super.key,
    required this.book,
    this.description,
    this.publisher,
    this.language,
    this.genres = const [],
  });

  final BookMetadata book;
  final String? description;
  final String? publisher;
  final String? language;
  final List<String> genres;

  @override
  State<BookSummary> createState() => _BookSummaryState();
}

class _BookSummaryState extends State<BookSummary> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.description ?? widget.book.description;
    final publisher = widget.publisher ?? widget.book.publisher;
    final language = widget.language ?? widget.book.language;
    final genres = widget.genres.isNotEmpty ? widget.genres : widget.book.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DescriptionCard(
          description: description,
          expanded: _expanded,
          onToggle: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
        ),
        const SizedBox(height: 12),
        _MetadataCard(
          genres: genres,
          language: language,
          publisher: publisher,
          publicationDate: widget.book.publicationDate,
          format: _fileFormat,
        ),
      ],
    );
  }

  String get _fileFormat {
    final extension = path.extension(widget.book.filePath);
    return extension.isEmpty
        ? 'Unknown'
        : extension.replaceFirst('.', '').toUpperCase();
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  final String? description;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = description?.trim();
    final canExpand = text != null && text.length > 220;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.28),
          width: 0.7,
        ),
      ),
      child: InkWell(
        onTap: canExpand ? onToggle : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'About the Book',
                      style: AppFonts.sectionHeading(
                        context,
                        fontSize: 14,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  if (canExpand)
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.gold,
                    ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                text?.isNotEmpty == true
                    ? text!
                    : 'No description is available for this book.',
                maxLines: expanded ? null : 6,
                overflow: expanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: AppFonts.body(context, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({
    required this.genres,
    required this.language,
    required this.publisher,
    required this.publicationDate,
    required this.format,
  });

  final List<String> genres;
  final String? language;
  final String? publisher;
  final String? publicationDate;
  final String format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Column(
          children: [
            _MetadataRow(
              icon: Icons.sell_outlined,
              label: 'Genre',
              value: genres.isEmpty ? null : genres.join(', '),
            ),
            _MetadataRow(
              icon: Icons.language_rounded,
              label: 'Language',
              value: language,
            ),
            _MetadataRow(
              icon: Icons.account_balance_outlined,
              label: 'Publisher',
              value: publisher,
            ),
            _MetadataRow(
              icon: Icons.calendar_month_outlined,
              label: 'Published',
              value: publicationDate,
            ),
            _MetadataRow(
              icon: Icons.description_outlined,
              label: 'Format',
              value: format,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 17, color: AppColors.gold),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppFonts.metadata(
                  context,
                  fontSize: 12,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value?.trim().isNotEmpty == true ? value! : '—',
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.metadata(context, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
      ],
    );
  }
}
