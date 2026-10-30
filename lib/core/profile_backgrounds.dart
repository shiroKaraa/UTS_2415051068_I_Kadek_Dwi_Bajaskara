import 'package:flutter/material.dart';

class ProfileBackgrounds {
  static const Map<String, List<Color>> presets = {
    'default': [Color(0xFF5FCB97), Color(0xFF17221D)], // Hijau 
    'sunset':  [Color(0xFFFF7E5F), Color(0xFFFEB47B)], // Senja
    'ocean':   [Color(0xFF2193b0), Color(0xFF6dd5ed)], // Laut
    'forest':  [Color(0xFF11998e), Color(0xFF38ef7d)], // Hutan
    'galaxy':  [Color(0xFF654ea3), Color(0xFFeaafc8)], // Galaxy
    'dark':    [Color(0xFF232526), Color(0xFF414345)], // Gelap
    'gold':    [Color(0xFFFDC830), Color(0xFFF37335)], // Emas
  };

  static List<Color> getGradient(String? key) {
    return presets[key] ?? presets['default']!;
  }
}