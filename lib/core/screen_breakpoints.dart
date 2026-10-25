import 'package:flutter/material.dart';

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
}