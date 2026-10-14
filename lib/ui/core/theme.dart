import 'package:flutter/material.dart';
import '../../domain/models/tile.dart';

class AppColors {
  // Tile Colors (High vibrancy + high contrast for light & dark)
  static const Color tileGreen = Color(0xFF10B981); // Emerald
  static const Color tilePink = Color(0xFFEC4899);  // Radiant Pink
  static const Color tileBlue = Color(0xFF2563EB);  // Vivid Blue
  static const Color tileRed = Color(0xFFDC2626);   // Bold Red
  static const Color tileYellow = Color(0xFFD97706); // Warm Amber/Yellow

  static Color colorForTileColor(TileColor color) {
    switch (color) {
      case TileColor.green:
        return tileGreen;
      case TileColor.pink:
        return tilePink;
      case TileColor.blue:
        return tileBlue;
      case TileColor.red:
        return tileRed;
      case TileColor.yellow:
        return tileYellow;
    }
  }

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkCard = Color(0xFF334155);       // Slate 700
  static const Color darkAccent = Color(0xFF6366F1);     // Indigo 500

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);       // Slate 100
  static const Color lightAccent = Color(0xFF4F46E5);    // Indigo 600
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccent,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
      onSurface: Color(0xFF0F172A),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
