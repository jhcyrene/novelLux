import 'package:flutter/material.dart';

import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class ReaderContentsSheet extends StatelessWidget {
  const ReaderContentsSheet({
    super.key,
    required this.chapterTitles,
    required this.currentChapter,
    required this.onChapterSelected,
  });

  final List<String> chapterTitles;
  final int currentChapter;
  final ValueChanged<int> onChapterSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            Text(
              'Contents',
              style: AppFonts.sectionHeading(context, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: chapterTitles.length,
                itemBuilder: (context, index) {
                  final selected = index == currentChapter;

                  return ListTile(
                    selected: selected,
                    selectedColor: AppColors.gold,
                    leading: Text(
                      '${index + 1}',
                      style: AppFonts.metadata(
                        context,
                        color: selected ? AppColors.gold : null,
                      ),
                    ),
                    title: Text(
                      chapterTitles[index],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        context,
                        fontSize: 14,
                        color: selected ? AppColors.gold : null,
                      ),
                    ),
                    onTap: () => onChapterSelected(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
