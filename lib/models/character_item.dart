import '../l10n/app_localizations.dart';

class KarakterAnime {
  final int id;
  final String nama;
  final String? namaNative;
  final String? imageUrl;
  final String? role;
  final String? voiceActorNama;
  final String? voiceActorImageUrl;
  final String? deskripsi;
  final String? gender;
  final String? age;

  const KarakterAnime({
    required this.id,
    required this.nama,
    this.namaNative,
    this.imageUrl,
    this.role,
    this.voiceActorNama,
    this.voiceActorImageUrl,
    this.deskripsi,
    this.gender,
    this.age,
  });

  factory KarakterAnime.fromEdge(Map<String, dynamic> edge) {
    final node = edge['node'] as Map<String, dynamic>? ?? {};
    final nameObj = node['name'] as Map<String, dynamic>?;
    final imageObj = node['image'] as Map<String, dynamic>?;
    final vas = edge['voiceActors'] as List<dynamic>?;
    Map<String, dynamic>? va;
    if (vas != null && vas.isNotEmpty) {
      va = vas.first as Map<String, dynamic>;
    }
    final vaNameObj = va?['name'] as Map<String, dynamic>?;
    final vaImageObj = va?['image'] as Map<String, dynamic>?;

    final fullName = nameObj?['full'] as String? ??
        nameObj?['native'] as String? ??
        'Tanpa Nama';

    return KarakterAnime(
      id: node['id'] as int,
      nama: fullName,
      namaNative: nameObj?['native'] as String?,
      imageUrl: imageObj?['large'] as String? ??
          imageObj?['medium'] as String?,
      role: edge['role'] as String?,
      voiceActorNama: vaNameObj?['full'] as String?,
      voiceActorImageUrl: vaImageObj?['large'] as String?,
      deskripsi: node['description'] as String?,
      gender: node['gender'] as String?,
      age: node['age'] as String?,
    );
  }

  bool get isMain => role == 'MAIN';

  String roleLabelOf(AppLocalizations l10n) {
    switch (role) {
      case 'MAIN':
        return l10n.characterMain;
      case 'SUPPORTING':
        return l10n.characterSupporting;
      case 'BACKGROUND':
        return l10n.characterBackground;
      default:
        return role ?? '-';
    }
  }
}