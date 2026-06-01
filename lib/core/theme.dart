import 'package:flutter/material.dart';

class AppColors {
  static const deep = Color(0xFF1E1B4B);
  static const surface = Color(0xFF2D2870);
  static const card = Color(0xFF3C3489);
  static const accent = Color(0xFF7F77DD);
  static const muted = Color(0xFF534AB7);
  static const soft = Color(0xFFAFA9EC);
  static const lighter = Color(0xFFCECBF6);
  static const text = Color(0xFFEEEDFE);
  static const navBg = Color(0xFF26215C);
  static const redDark = Color(0xFFA32D2D);
  static const redLight = Color(0xFFFCEBEB);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.deep,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
          onPrimary: AppColors.text,
          onSurface: AppColors.text,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          labelStyle: const TextStyle(color: AppColors.soft),
          hintStyle: const TextStyle(color: AppColors.soft),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.muted),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.redDark),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.redDark, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.text,
            disabledBackgroundColor: AppColors.muted,
            disabledForegroundColor: AppColors.soft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.navBg,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.soft,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.muted
                : AppColors.card,
          ),
        ),
        dividerColor: AppColors.muted,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.text),
          bodySmall: TextStyle(color: AppColors.soft),
          titleMedium: TextStyle(color: AppColors.text),
          titleLarge:
              TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        ),
      );
}
