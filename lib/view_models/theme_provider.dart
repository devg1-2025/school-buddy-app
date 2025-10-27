// lib/view_models/theme_provider.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  ThemeProvider({bool? isDarkMode}) : _isDarkMode = isDarkMode ?? false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setThemeFromSystem(Brightness brightness) {
    final shouldBeDark = brightness == Brightness.dark;
    if (_isDarkMode != shouldBeDark) {
      _isDarkMode = shouldBeDark;
      notifyListeners();
    }
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // ---------------------------
  // ☀️ Light Theme
  // ---------------------------
  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(AppColors.homeBgColor),
        colorScheme: ColorScheme.light(
          primary: Color(AppColors.primaryColor),
          secondary: const Color(0xFFF4A261),
          surface: Colors.white,
        ),
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(AppColors.primaryColor),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF4A261),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          labelLarge: TextStyle(color: Colors.black87),
        ),
      );

  // ---------------------------
  // 🌙 Dark Theme (World-Class Reading Mode)
  // ---------------------------
  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C1214), // calm, near-black teal
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF18A57A), // softened teal
          secondary: Color(0xFFE3A86B), // warm muted amber
          surface: Color(0xFF162022), // low-contrast cards
        ),
        cardColor: const Color(0xFF162022),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10191B),
          foregroundColor: Color(0xFFEAEFEF),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF18A57A),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFFD8E2E1), // soft light gray
            fontSize: 15.5,
            height: 1.6,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFB0BCBA),
            fontSize: 14.5,
            height: 1.55,
          ),
          labelLarge: TextStyle(color: Color(0xFFD8E2E1)),
        ),
        dividerColor: Colors.grey.withOpacity(0.15),
        shadowColor: Colors.black.withOpacity(0.3),
      );

  // ---------------------------
  // 🎨 Convenience Colors
  // ---------------------------

  Color get backgroundColor =>
      _isDarkMode ? const Color(0xFF0C1214) : const Color(AppColors.homeBgColor);

  Color get textColor =>
      _isDarkMode ? const Color(0xFFD8E2E1) : Colors.grey[900]!;

  Color get subTextColor =>
      _isDarkMode ? Colors.grey[500]! : Colors.grey[600]!;

  Color get cardColor => _isDarkMode ? const Color(0xFF162022) : Colors.white;

  Color get shadowColor => _isDarkMode
      ? Colors.black.withOpacity(0.3)
      : Colors.grey.withOpacity(0.15);

  Color get primary =>
      _isDarkMode ? const Color(0xFF18A57A) : Color(AppColors.primaryColor);

  Color get accent =>
      _isDarkMode ? const Color(0xFFE3A86B) : const Color(0xFFF4A261);

  // Subtle gradient for headers or banners
  Color get bannerStart =>
      _isDarkMode ? const Color(0xFF1BA37C) : Color(AppColors.primaryColor);

  Color get bannerEnd => _isDarkMode
      ? const Color(0xFF11715B)
      : Color(AppColors.primaryColor).withOpacity(0.8);

  // Variants for dynamic card accents
  Color get cardColor1 =>
      _isDarkMode ? const Color(0xFF1B2630) : const Color(0xFFF7F4A3);

  Color get cardColor2 =>
      _isDarkMode ? const Color(0xFF232E36) : const Color(0xFFA3B5F7);

  // ---------------------------
  // ✨ Text Styles
  // ---------------------------
  TextStyle get titleStyle => TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      );

  TextStyle get subtitleStyle => TextStyle(
        color: subTextColor,
        fontSize: 14.5,
      );
}
