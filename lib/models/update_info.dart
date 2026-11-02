class UpdateInfo {
  final String tagName;
  final String version;
  final String releaseName;
  final String body;
  final String apkUrl;
  final int apkSize;
  final DateTime publishedAt;

  const UpdateInfo({
    required this.tagName,
    required this.version,
    required this.releaseName,
    required this.body,
    required this.apkUrl,
    required this.apkSize,
    required this.publishedAt,
  });

  factory UpdateInfo.fromGitHub(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String;
    final assets = (json['assets'] as List<dynamic>?) ?? [];

    Map<String, dynamic>? apkAsset;
    for (final a in assets) {
      final name = (a['name'] as String).toLowerCase();
      if (name.endsWith('.apk') && name.contains('tsuzuki')) {
        apkAsset = a as Map<String, dynamic>;
        break;
      }
    }

    if (apkAsset == null) {
      throw Exception('Tidak ada file APK di release ini.');
    }

    return UpdateInfo(
      tagName: tag,
      version: tag.replaceFirst('v', ''),
      releaseName: json['name'] as String? ?? tag,
      body: json['body'] as String? ?? 'Tidak ada catatan rilis.',
      apkUrl: apkAsset['browser_download_url'] as String,
      apkSize: apkAsset['size'] as int? ?? 0,
      publishedAt: DateTime.parse(json['published_at'] as String),
    );
  }
}