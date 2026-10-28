import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryGreen,
      cardColor: AppColors.darkCard,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.infoBlue,
        surface: AppColors.darkCard,
        error: Colors.redAccent,
      ),
      // 👇 CardTheme global — dark
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textLight),
        bodyMedium: TextStyle(color: AppColors.textLight),
        titleLarge: TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.textLight, fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryGreen);
          }
          return const IconThemeData(color: AppColors.textLight);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkCard,
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        selectedLabelTextStyle:
            const TextStyle(color: AppColors.textLight, fontSize: 12),
        unselectedLabelTextStyle:
            const TextStyle(color: AppColors.textLight, fontSize: 12),
        selectedIconTheme:
            const IconThemeData(color: AppColors.primaryGreen),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.textLight),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primaryGreenDark,
      cardColor: AppColors.lightCard,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreenDark,
        secondary: AppColors.infoBlue,
        surface: AppColors.lightCard,
        error: Colors.redAccent,
      ),
      // 👇 CardTheme global — light
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark),
        titleLarge: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightCard,
        indicatorColor: AppColors.primaryGreenDark.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: AppColors.textDark, fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryGreenDark);
          }
          return const IconThemeData(color: AppColors.textDark);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightCard,
        indicatorColor: AppColors.primaryGreenDark.withValues(alpha: 0.2),
        selectedLabelTextStyle:
            const TextStyle(color: AppColors.textDark, fontSize: 12),
        unselectedLabelTextStyle:
            const TextStyle(color: AppColors.textDark, fontSize: 12),
        selectedIconTheme:
            const IconThemeData(color: AppColors.primaryGreenDark),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.textDark),
      ),
    );
  }
}