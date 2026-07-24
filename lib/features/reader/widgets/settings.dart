import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import 'display_tab.dart';

class ReaderSettingsSheet extends StatelessWidget {
  const ReaderSettingsSheet({
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading appearance',
              style: AppFonts.sectionHeading(context, fontSize: 20),
            ),
            const SizedBox(height: 18),
            ReaderDisplayTab(
              readingFont: readingFont,
              fontSize: fontSize,
              onFontChanged: onFontChanged,
              onFontSizeChanged: onFontSizeChanged,
            ),
          ],
        ),
      ),
    );
  }
}
