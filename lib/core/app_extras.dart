import 'package:flutter/material.dart';
import '../models/media_type_enum.dart';
import '../models/status_collection_enum.dart';

@immutable
class AppExtras extends ThemeExtension<AppExtras> {
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color success;
  final Color warning;
  final Color gold;
  final Color anime;
  final Color manga;
  final Color manhwa;
  final Color manhua;
  final Color other;
  
  final Color statusActive;
  final Color statusDone;
  final Color statusHold;
  final Color statusDropped;
  final Color statusPlan;

  const AppExtras({
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.success,
    required this.warning,
    required this.gold,
    required this.anime,
    required this.manga,
    required this.manhwa,
    required this.manhua,
    required this.other,
    required this.statusActive,
    required this.statusDone,
    required this.statusHold,
    required this.statusDropped,
    required this.statusPlan,
  });

  static const dark = AppExtras(
    shimmerBase: Color(0xFF2C3A33),
    shimmerHighlight: Color(0xFF3D4F46),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    gold: Color(0xFFE3B964),
    anime: Color(0xFF6FA8E8),
    manga: Color(0xFFE88A7A),
    manhwa: Color(0xFFE3B964),
    manhua: Color(0xFFB08AE8),
    other: Color(0xFF8C9E96),
    statusActive: Color(0xFF5FCB97),
    statusDone: Color(0xFF6FA8E8),
    statusHold: Color(0xFFE3B964),
    statusDropped: Color(0xFFE57373),
    statusPlan: Color(0xFF8C9E96),
  );

  static const light = AppExtras(
    shimmerBase: Color(0xFFE3EAE6),
    shimmerHighlight: Color(0xFFF4F7F5),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFB26A00),
    gold: Color(0xFF8A6A1F),
    anime: Color(0xFF2F6DB5),
    manga: Color(0xFFB4442F),
    manhwa: Color(0xFF8A6A1F),
    manhua: Color(0xFF6F42B5),
    other: Color(0xFF5E7068),
    statusActive: Color(0xFF2E7D57),
    statusDone: Color(0xFF2F6DB5),
    statusHold: Color(0xFF8A6A1F),
    statusDropped: Color(0xFFC62828),
    statusPlan: Color(0xFF52625A),
  );

  Color typeColor(JenisMedia j) => switch (j) {
        JenisMedia.anime => anime,
        JenisMedia.manga => manga,
        JenisMedia.manhwa => manhwa,
        JenisMedia.manhua => manhua,
        _ => other,
      };

  Color statusColor(StatusKoleksi s) => switch (s) {
        StatusKoleksi.selesai => statusDone,
        StatusKoleksi.sedang => statusActive,
        StatusKoleksi.ditunda => statusHold,
        StatusKoleksi.dihentikan => statusDropped,
        StatusKoleksi.direncanakan => statusPlan,
      };

  @override
  AppExtras copyWith({
    Color? shimmerBase, Color? shimmerHighlight, Color? success,
    Color? warning, Color? gold, Color? anime, Color? manga,
    Color? manhwa, Color? manhua, Color? other,
    Color? statusActive, Color? statusDone, Color? statusHold,
    Color? statusDropped, Color? statusPlan,
  }) {
    return AppExtras(
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      gold: gold ?? this.gold,
      anime: anime ?? this.anime,
      manga: manga ?? this.manga,
      manhwa: manhwa ?? this.manhwa,
      manhua: manhua ?? this.manhua,
      other: other ?? this.other,
      statusActive: statusActive ?? this.statusActive,
      statusDone: statusDone ?? this.statusDone,
      statusHold: statusHold ?? this.statusHold,
      statusDropped: statusDropped ?? this.statusDropped,
      statusPlan: statusPlan ?? this.statusPlan,
    );
  }

  @override
  AppExtras lerp(AppExtras? o, double t) {
    if (o == null) return this;
    return AppExtras(
      shimmerBase: Color.lerp(shimmerBase, o.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, o.shimmerHighlight, t)!,
      success: Color.lerp(success, o.success, t)!,
      warning: Color.lerp(warning, o.warning, t)!,
      gold: Color.lerp(gold, o.gold, t)!,
      anime: Color.lerp(anime, o.anime, t)!,
      manga: Color.lerp(manga, o.manga, t)!,
      manhwa: Color.lerp(manhwa, o.manhwa, t)!,
      manhua: Color.lerp(manhua, o.manhua, t)!,
      other: Color.lerp(other, o.other, t)!,
      statusActive: Color.lerp(statusActive, o.statusActive, t)!,
      statusDone: Color.lerp(statusDone, o.statusDone, t)!,
      statusHold: Color.lerp(statusHold, o.statusHold, t)!,
      statusDropped: Color.lerp(statusDropped, o.statusDropped, t)!,
      statusPlan: Color.lerp(statusPlan, o.statusPlan, t)!,
    );
  }
}

extension AppThemeX on BuildContext {
  AppExtras get extras => Theme.of(this).extension<AppExtras>()!;
}