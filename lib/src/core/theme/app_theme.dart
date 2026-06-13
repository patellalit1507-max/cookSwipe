import 'package:flutter/material.dart';

/// CookSwipe design language: clean, modern, minimal, card-first.
/// Warm saffron primary — food-friendly and distinctly Indian.
class AppTheme {
  AppTheme._();

  static const Color saffron = Color(0xFFFF6B35);
  static const Color deepCharcoal = Color(0xFF1F1A17);
  static const Color softCream = Color(0xFFFFF8F3);
  static const Color vegGreen = Color(0xFF2E7D32);
  static const Color nonVegRed = Color(0xFFC62828);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: saffron,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: softCream,
      appBarTheme: AppBarTheme(
        backgroundColor: softCream,
        foregroundColor: deepCharcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: deepCharcoal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: saffron,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
