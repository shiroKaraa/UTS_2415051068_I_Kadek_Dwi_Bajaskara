enum NsfwFilterLevel {
  off,
  light,
  heavy,
}

class NsfwSettings {
  final bool enabled;
  final bool blurCovers;
  final bool blurTitles;
  final bool hideBadge;
  final NsfwFilterLevel filterLevel;

  const NsfwSettings({
    this.enabled = false,
    this.blurCovers = true,
    this.blurTitles = false,
    this.hideBadge = false,
    this.filterLevel = NsfwFilterLevel.light,
  });

  NsfwSettings copyWith({
    bool? enabled,
    bool? blurCovers,
    bool? blurTitles,
    bool? hideBadge,
    NsfwFilterLevel? filterLevel,
  }) {
    return NsfwSettings(
      enabled: enabled ?? this.enabled,
      blurCovers: blurCovers ?? this.blurCovers,
      blurTitles: blurTitles ?? this.blurTitles,
      hideBadge: hideBadge ?? this.hideBadge,
      filterLevel: filterLevel ?? this.filterLevel,
    );
  }

  bool get shouldSensorCover =>
      enabled && blurCovers && filterLevel != NsfwFilterLevel.off;

  bool get shouldSensorTitle =>
      enabled && blurTitles && filterLevel != NsfwFilterLevel.off;

  bool get shouldHideBadge => enabled && hideBadge;

  bool get isHeavyMode => enabled && filterLevel == NsfwFilterLevel.heavy;
}