import 'package:flutter/material.dart';

class TitikLayar {
  TitikLayar._();

  static const double compact = 600.0;
  static const double medium = 840.0;

  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compact;
  }

  static bool isExpanded(BuildContext context) {
    return MediaQuery.of(context).size.width >= medium;
  }
}