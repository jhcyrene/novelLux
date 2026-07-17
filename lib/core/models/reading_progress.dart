class ReadingProgress {
  const ReadingProgress({
    required this.bookId,
    required this.chapterTitle,
    required this.chapterIndex,
    required this.totalChapters,
    required this.chapterProgress,
    required this.lastOpenedAt,
  });

  final String bookId;
  final String chapterTitle;
  final int chapterIndex;
  final int totalChapters;

  // Position inside the current chapter: 0.0 to 1.0.
  final double chapterProgress;

  final DateTime lastOpenedAt;

  double get percentage {
    if (totalChapters <= 0) {
      return 0;
    }

    final progress =
        (chapterIndex + chapterProgress) / totalChapters;

    return progress.clamp(0.0, 1.0).toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'chapterTitle': chapterTitle,
      'chapterIndex': chapterIndex,
      'totalChapters': totalChapters,
      'chapterProgress': chapterProgress,
      'lastOpenedAt': lastOpenedAt.toIso8601String(),
    };
  }// get the data to json

  factory ReadingProgress.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReadingProgress(
      bookId: json['bookId'] as String,
      chapterTitle:
          json['chapterTitle'] as String? ?? 'Current chapter',
      chapterIndex: json['chapterIndex'] as int? ?? 0,
      totalChapters: json['totalChapters'] as int? ?? 1,
      chapterProgress:
          (json['chapterProgress'] as num?)?.toDouble() ?? 0,
      lastOpenedAt: DateTime.tryParse(
            json['lastOpenedAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}