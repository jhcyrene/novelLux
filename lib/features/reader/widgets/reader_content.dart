import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class ReaderContent extends StatelessWidget {
  const ReaderContent({
    super.key,
    required this.scrollController,
    required this.chapterTitle,
    required this.htmlContent,
    required this.readingFont,
    required this.fontSize,
    required this.onScrollEnd,
  });

  final ScrollController scrollController;
  final String chapterTitle;
  final String htmlContent;
  final ReadingFontFamily readingFont;
  final double fontSize;
  final FutureOr<void> Function() onScrollEnd;

  @override
  Widget build(BuildContext context) {
    final readingStyle = AppFonts.readingContent(
      context,
      fontFamily: readingFont,
      fontSize: fontSize,
    );

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        unawaited(Future<void>.sync(onScrollEnd));
        return false;
      },
      child: SelectionArea(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                chapterTitle,
                textAlign: TextAlign.center,
                style: AppFonts.chapterTitle(context, fontSize: 32),
              ),
              const SizedBox(height: 14),
              const _ChapterDivider(),
              const SizedBox(height: 18),
              RepaintBoundary(
                child: Html(
                  data: htmlContent,
                  style: {
                    'html': Style.fromTextStyle(readingStyle),
                    'body': Style.fromTextStyle(readingStyle),
                    'p': Style.fromTextStyle(readingStyle),
                    'img': Style(
                      width: Width(100, Unit.percent),
                      margin: Margins.symmetric(vertical: 12),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterDivider extends StatelessWidget {
  const _ChapterDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.gold, thickness: 0.7)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.auto_awesome, size: 15, color: AppColors.gold),
        ),
        Expanded(child: Divider(color: AppColors.gold, thickness: 0.7)),
      ],
    );
  }
}
