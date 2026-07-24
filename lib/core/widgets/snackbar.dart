import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum SnackBarType { info, success, warning, error }

abstract final class SnackBarNotif {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final colors = _colorsFor(type);

    messenger.hideCurrentSnackBar();

    return messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        duration: duration,
        backgroundColor: colors.background,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.accent.withValues(alpha: 0.35)),
        ),
        content: Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconFor(type), size: 20, color: colors.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: colors.accent,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    return show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    return show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static IconData _iconFor(SnackBarType type) {
    return switch (type) {
      SnackBarType.info => Icons.info_outline_rounded,
      SnackBarType.success => Icons.check_rounded,
      SnackBarType.warning => Icons.warning_amber_rounded,
      SnackBarType.error => Icons.close_rounded,
    };
  }

  static _SnackBarColors _colorsFor(SnackBarType type) {
    return switch (type) {
      SnackBarType.info => const _SnackBarColors(
        background: AppColors.slateBlue,
        accent: AppColors.ivory,
      ),
      SnackBarType.success => const _SnackBarColors(
        background: Color(0xFF17231C),
        accent: Color(0xFF72D49A),
      ),
      SnackBarType.warning => const _SnackBarColors(
        background: Color(0xFF2B2114),
        accent: AppColors.gold,
      ),
      SnackBarType.error => const _SnackBarColors(
        background: Color(0xFF2B1717),
        accent: Color(0xFFFF8A80),
      ),
    };
  }
}

class _SnackBarColors {
  const _SnackBarColors({required this.background, required this.accent});

  final Color background;
  final Color accent;
}
