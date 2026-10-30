import 'package:flutter/material.dart';

enum WindowSize {
  compact,
  medium,
  expanded,
  large;

  static WindowSize fromWidth(double w) {
    if (w >= 1200) return large;
    if (w >= 840) return expanded;
    if (w >= 600) return medium;
    return compact;
  }
}

class ScreenBreakpoints {
  ScreenBreakpoints._();

  static const double compact = 600.0;
  static const double medium = 840.0;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compact;
  }

  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= medium;
  }

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compact && width < medium;
  }

  static WindowSize windowSizeOf(BuildContext context) {
    return WindowSize.fromWidth(MediaQuery.sizeOf(context).width);
  }
}