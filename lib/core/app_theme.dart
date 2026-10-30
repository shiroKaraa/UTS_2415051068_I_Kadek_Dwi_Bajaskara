import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_extras.dart';
import 'app_sizes.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData dark = _build(_darkScheme, AppExtras.dark);
  static final ThemeData light = _build(_lightScheme, AppExtras.light);

  static ThemeData get darkTheme => dark;
  static ThemeData get lightTheme => light;

  static const _darkScheme = ColorScheme.dark(
    primary: AppColors.primaryGreen,
    onPrimary: Colors.black,
    secondary: AppColors.infoBlue,
    onSecondary: Colors.black,
    surface: AppColors.darkBackground,
    onSurface: AppColors.textLight,
    onSurfaceVariant: Color(0xFFA9B8B0),
    surfaceContainerLow: Color(0xFF131C18),
    surfaceContainer: AppColors.darkCard,
    surfaceContainerHighest: Color(0xFF26332C),
    outline: Color(0xFF5B6B63),
    outlineVariant: Color(0xFF2A3731),
    error: AppColors.danger,
  );

  static const _lightScheme = ColorScheme.light(
    primary: Color(0xFF2E7D57),
    onPrimary: Colors.white,
    secondary: AppColors.infoBlue,
    surface: AppColors.lightBackground,
    onSurface: AppColors.textDark,
    onSurfaceVariant: Color(0xFF52625A),
    surfaceContainer: AppColors.lightCard,
    surfaceContainerHighest: Color(0xFFE3EAE6),
    outline: Color(0xFF8A9A92),
    outlineVariant: Color(0xFFD5DED9),
    error: Color(0xFFC62828),
  );

  static ThemeData _build(ColorScheme s, AppExtras extras) {
    final isDark = s.brightness == Brightness.dark;

    final baseTextTheme =
        GoogleFonts.plusJakartaSansTextTheme(
                ThemeData(brightness: s.brightness).textTheme)
            .apply(bodyColor: s.onSurface, displayColor: s.onSurface);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: s,
      scaffoldBackgroundColor: s.surface,
      extensions: [extras],
      textTheme: baseTextTheme,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: s.surface,
        foregroundColor: s.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: s.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: BorderSide(color: s.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: s.primary,
          foregroundColor: s.onPrimary,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: s.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: s.primary,
        foregroundColor: s.onPrimary,
      ),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: Colors.transparent,
        selectedColor: s.primary.withValues(alpha: 0.18),
        side: BorderSide(color: s.outlineVariant),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: s.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.surfaceContainer,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusL + 4),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: s.primary),
      dividerTheme: DividerThemeData(color: s.outlineVariant, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: s.surfaceContainer,
        indicatorColor: s.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((st) => TextStyle(
              fontSize: 12,
              fontWeight: st.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: st.contains(WidgetState.selected)
                  ? s.primary
                  : s.onSurfaceVariant,
            )),
        iconTheme: WidgetStateProperty.resolveWith((st) => IconThemeData(
              color: st.contains(WidgetState.selected)
                  ? s.primary
                  : s.onSurfaceVariant,
            )),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: s.surfaceContainer,
        indicatorColor: s.primary.withValues(alpha: 0.2),
        selectedIconTheme: IconThemeData(color: s.primary),
        unselectedIconTheme: IconThemeData(color: s.onSurfaceVariant),
      ),
    );
  }
}