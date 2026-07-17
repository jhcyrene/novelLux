import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_progress.dart';

class ReadingProgressProvider extends ChangeNotifier {
  static const String _storageKey =
      'novellux_reading_progress';

  final Map<String, ReadingProgress> _history = {};

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<ReadingProgress> get history {
    final values = _history.values.toList();

    values.sort(
      (a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt),
    );

    return values;
  }

  ReadingProgress? get mostRecent {
    final items = history;

    if (items.isEmpty) {
      return null;
    }

    return items.first;
  }

  ReadingProgress? progressFor(String bookId) {
    return _history[bookId];
  }

  Future<void> loadProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      final preferences =
          await SharedPreferences.getInstance();

      final savedValue =
          preferences.getString(_storageKey);

      if (savedValue == null || savedValue.isEmpty) {
        return;
      }

      final decoded = jsonDecode(savedValue);

      if (decoded is! List) {
        return;
      }

      _history.clear();

      for (final item in decoded) {
        final progress = ReadingProgress.fromJson(
          Map<String, dynamic>.from(item as Map),
        );

        _history[progress.bookId] = progress;
      }
    } catch (error) {
      debugPrint(
        'Unable to load reading progress: $error',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProgress({
    required String bookId,
    required String chapterTitle,
    required int chapterIndex,
    required int totalChapters,
    required double chapterProgress,
  }) async {
    _history[bookId] = ReadingProgress(
      bookId: bookId,
      chapterTitle: chapterTitle,
      chapterIndex: chapterIndex,
      totalChapters: totalChapters,
      chapterProgress:
          chapterProgress.clamp(0.0, 1.0).toDouble(),
      lastOpenedAt: DateTime.now(),
    );

    notifyListeners();

    await _saveToStorage();
  }

  Future<void> removeProgress(String bookId) async {
    _history.remove(bookId);

    notifyListeners();

    await _saveToStorage();
  }

  Future<void> clearProgress() async {
    _history.clear();

    notifyListeners();

    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }

  Future<void> _saveToStorage() async {
    try {
      final preferences =
          await SharedPreferences.getInstance();

      final encoded = jsonEncode(
        _history.values
            .map((progress) => progress.toJson())
            .toList(),
      );

      await preferences.setString(
        _storageKey,
        encoded,
      );
    } catch (error) {
      debugPrint(
        'Unable to save reading progress: $error',
      );
    }
  }
}