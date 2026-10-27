import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/collection_entry.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';
import 'cover_image.dart';

class CollectionCard extends StatelessWidget {
  final EntriKoleksi entri;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CollectionCard({
    super.key,
    required this.entri,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (entri.total != null && entri.total! > 0)
        ? (entri.progres / entri.total!).clamp(0.0, 1.0)
        : 0.0;
    final isSelesai = entri.status == StatusKoleksi.selesai;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CoverImage(url: entri.coverUrl),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isSelesai && entri.total != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Material(
                        color: AppColors.primaryGreen,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () async {
                            final provider = context.read<CollectionProvider>();
                            if (provider.isOffline) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Tidak dapat menambah progres saat offline.')),
                              );
                              return;
                            }

                            await provider.incrementProgress(entri);

                            if (!context.mounted) return;
                            if (provider.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(provider.errorMessage!)),
                              );
                              return;
                            }

                            final updated = provider.allEntries.firstWhere(
                              (e) => e.id == entri.id,
                              orElse: () => entri,
                            );

                            if (updated.status == StatusKoleksi.selesai) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Selamat! Kamu telah menamatkan judul ini.')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Progres +1 berhasil.')),
                              );
                            }
                          },
                          customBorder: const CircleBorder(),
                          // Padding diperbesar agar tap target mencapai 48px (Aksesibilitas)
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Icon(Icons.add,
                                color: Colors.black, size: 24),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entri.judul,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            entri.status.netralLabel,
            style: TextStyle(fontSize: 11, color: AppColors.infoBlue),
          ),
          Text(
            '${entri.progres}/${entri.total ?? "?"}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: AppColors.primaryGreen,
            minHeight: 3,
          ),
        ],
      ),
    );
  }
}