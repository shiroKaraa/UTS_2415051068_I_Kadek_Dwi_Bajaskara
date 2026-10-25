import 'package:flutter/material.dart';

/// Controller global untuk ThemeMode.
/// Diubah dari menu "Tema Aplikasi" di OtherPage (tahap berikutnya).
class ThemeController {
  ThemeController._();

  /// Notifier global — dengarkan dengan ValueListenableBuilder.
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Ubah mode tema.
  static void setMode(ThemeMode newMode) {
    mode.value = newMode;
  }

  /// Toggle cepat antara light dan dark (opsional).
  static void toggle() {
    mode.value = mode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }
}