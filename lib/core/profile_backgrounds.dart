import 'package:flutter/material.dart';

class ProfileBackgrounds {
  ProfileBackgrounds._();

  static const Map<String, List<Color>> presets = {
    'default': [Color(0xFF5FCB97), Color(0xFF17221D)],
    'sunset':  [Color(0xFFFF7E5F), Color(0xFFFEB47B)],
    'ocean':   [Color(0xFF2193b0), Color(0xFF6dd5ed)],
    'forest':  [Color(0xFF11998e), Color(0xFF38ef7d)],
    'galaxy':  [Color(0xFF654ea3), Color(0xFFeaafc8)],
    'dark':    [Color(0xFF232526), Color(0xFF414345)],
    'gold':    [Color(0xFFFDC830), Color(0xFFF37335)],
  };

  static List<Color> getGradient(String? key) {
    return presets[key] ?? presets['default']!;
  }

  static Color onGradient(String? key) {
    final colors = getGradient(key);
    final avg = colors.map((c) => c.computeLuminance()).reduce((a, b) => a + b) / colors.length;
    return avg > 0.5 ? Colors.black87 : Colors.white;
  }
}