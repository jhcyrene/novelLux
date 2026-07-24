import 'package:flutter/material.dart';
import 'app_font.dart';

abstract class AppColors {
  static const Color deepBlack = Color(
    0xFF0D0D0D,
  ); // deep black (logo background)
  static const Color slateBlue = Color(
    0xFF1E2128,
  ); // dark charcoal (secondary swatch)
  static const Color gold = Color(
    0xFFD9A441,
  ); // bright gold (book/sparkle gradient)
  static const Color cream = Color(0xFFB8802E); // bronze/darker gold accent
  static const Color ivory = Color(0xFFF0D9AF); // light tan/cream
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF2F3F5);
  static const Color gray = Color(0xFF121416);

  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.deepBlack,
      brightness: Brightness.light,
      primary: AppColors.deepBlack,
      secondary: AppColors.white,
      surface: AppColors.ivory,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
      textTheme: AppFonts.interfaceTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.deepBlack,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightGray,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.deepBlack,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 23),
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      primary: AppColors.gold,
      secondary: AppColors.slateBlue,
      surface: AppColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppFonts.interfaceTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.gray,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color.fromARGB(207, 20, 20, 20),
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.white70,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
