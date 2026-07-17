import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ReadingFontFamily {
  literata,
  lora,
  merriweather,
  notoSerif,
  system,
}

extension ReadingFontFamilyName on ReadingFontFamily {
  String get displayName {
    switch (this) {
      case ReadingFontFamily.literata:
        return 'Literata';
      case ReadingFontFamily.lora:
        return 'Lora';
      case ReadingFontFamily.merriweather:
        return 'Merriweather';
      case ReadingFontFamily.notoSerif:
        return 'Noto Serif';
      case ReadingFontFamily.system:
        return 'System Default';
    }
  }
}

abstract final class AppFonts {
  // Default font selected for reading EPUB content.
  static const ReadingFontFamily defaultReadingFont =
      ReadingFontFamily.literata;

  // Used by ThemeData for normal interface text.
  static TextTheme interfaceTextTheme(Brightness brightness) {
    final defaultTextTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return GoogleFonts.interTextTheme(defaultTextTheme);
  }

  // NovelLux logo/brand.
  static TextStyle brand(
    BuildContext context, {
    double fontSize = 32,
    Color? color,
  }) {
    final theme = Theme.of(context);

    return GoogleFonts.bodoniModa(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: color ?? theme.colorScheme.onSurface,
    );
  }

  // General page titles.
  static TextStyle pageTitle(
    BuildContext context, {
    double fontSize = 28,
    Color? color,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  // Chapter titles inside the reader.
  static TextStyle chapterTitle(
    BuildContext context, {
    double fontSize = 34,
    Color? color,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle emptyStateTitle(
    BuildContext context, {
    double fontSize = 24,
    Color? color,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.15,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle bookTitle(
    BuildContext context, {
    double fontSize = 16,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle sectionHeading(
    BuildContext context, {
    double fontSize = 19,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle body(
    BuildContext context, {
    double fontSize = 14,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: color ??
          Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle author(
    BuildContext context, {
    double fontSize = 13,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ??
          Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle button(
    BuildContext context, {
    double fontSize = 14,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle navigationLabel(
    BuildContext context, {
    double fontSize = 12,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  static TextStyle metadata(
    BuildContext context, {
    double fontSize = 12,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color ??
          Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  // Font selected by the user for EPUB reading content.
  static TextStyle readingContent(
    BuildContext context, {
    ReadingFontFamily fontFamily = defaultReadingFont,
    double fontSize = 20,
    double lineHeight = 1.65,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    final textColor =
        color ?? Theme.of(context).colorScheme.onSurface;

    switch (fontFamily) {
      case ReadingFontFamily.literata:
        return GoogleFonts.literata(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: lineHeight,
          color: textColor,
        );

      case ReadingFontFamily.lora:
        return GoogleFonts.lora(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: lineHeight,
          color: textColor,
        );

      case ReadingFontFamily.merriweather:
        return GoogleFonts.merriweather(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: lineHeight,
          color: textColor,
        );

      case ReadingFontFamily.notoSerif:
        return GoogleFonts.notoSerif(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: lineHeight,
          color: textColor,
        );

      case ReadingFontFamily.system:
        return TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: lineHeight,
          color: textColor,
        );
    }
  }
}