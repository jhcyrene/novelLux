import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class ReaderDisplayTab extends StatelessWidget {
  const ReaderDisplayTab({
    super.key,
    required this.readingFont,
    required this.fontSize,
    required this.onFontChanged,
    required this.onFontSizeChanged,
  });

  final ReadingFontFamily readingFont;
  final double fontSize;
  final ValueChanged<ReadingFontFamily> onFontChanged;
  final ValueChanged<double> onFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Font', style: AppFonts.body(context, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<ReadingFontFamily>(
          initialValue: readingFont,
          decoration: const InputDecoration(isDense: true),
          items: ReadingFontFamily.values
              .map(
                (font) => DropdownMenuItem(
                  value: font,
                  child: Text(font.displayName),
                ),
              )
              .toList(growable: false),
          onChanged: (font) {
            if (font != null) {
              onFontChanged(font);
            }
          },
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text('A', style: AppFonts.body(context, fontSize: 14)),
            Expanded(
              child: Slider(
                value: fontSize,
                min: 12,
                max: 28,
                divisions: 12,
                activeColor: AppColors.gold,
                label: fontSize.round().toString(),
                onChanged: onFontSizeChanged,
              ),
            ),
            Text('A', style: AppFonts.body(context, fontSize: 24)),
          ],
        ),
      ],
    );
  }
}
