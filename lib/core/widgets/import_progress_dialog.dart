import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_font.dart';
import '../theme/app_theme.dart';

class ImportProgressData {
  const ImportProgressData({
    required this.progress,
    required this.status,
    this.fileName,
    this.currentFile = 0,
    this.totalFiles = 0,
  });

  final double progress;
  final String status;
  final String? fileName;
  final int currentFile;
  final int totalFiles;
}

class ImportProgressDialog extends StatelessWidget {
  const ImportProgressDialog({super.key, required this.progress});

  final ValueListenable<ImportProgressData> progress;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: ValueListenableBuilder<ImportProgressData>(
            valueListenable: progress,
            builder: (context, data, _) {
              final percentage = (data.progress * 100).round();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.library_add_outlined,
                      color: AppColors.gold,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Importing ebooks',
                    textAlign: TextAlign.center,
                    style: AppFonts.sectionHeading(context, fontSize: 18),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    data.status,
                    textAlign: TextAlign.center,
                    style: AppFonts.body(context, fontSize: 13),
                  ),
                  if (data.fileName != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      data.fileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppFonts.metadata(
                        context,
                        fontSize: 11,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: data.progress.clamp(0, 1),
                      minHeight: 7,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.totalFiles > 0
                            ? '${data.currentFile} of ${data.totalFiles}'
                            : 'Preparing',
                        style: AppFonts.metadata(context, fontSize: 11),
                      ),
                      Text(
                        '$percentage%',
                        style: AppFonts.metadata(
                          context,
                          fontSize: 11,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
