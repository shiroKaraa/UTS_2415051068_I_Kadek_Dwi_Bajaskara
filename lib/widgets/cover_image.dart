import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/settings_provider.dart';
import '../core/app_cache_manager.dart';

class CoverImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  const CoverImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final limitCache =
        context.select<SettingsProvider, bool>((s) => s.limitImageCache);

    Widget placeholder(IconData icon) => Container(
          width: width,
          height: height,
          color: scheme.surfaceContainerHighest,
          child: Icon(icon, color: scheme.onSurfaceVariant, size: 32),
        );

    if (url == null || url!.isEmpty) {
      return placeholder(Icons.image_outlined);
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memWidth = width != null && width!.isFinite
        ? (width! * dpr).round()
        : 300;
    final memHeight = height != null && height!.isFinite
        ? (height! * dpr).round()
        : null;

    final int? diskMaxWidth = limitCache ? 400 : null;
    final int? diskMaxHeight = limitCache ? 600 : null;

    return FutureBuilder<CacheManager>(
      future: AppCacheManager.getInstance(),
      builder: (context, snapshot) {
        return CachedNetworkImage(
          imageUrl: url!,
          width: width,
          height: height,
          fit: fit,
          cacheManager: snapshot.data,
          memCacheWidth: memWidth,
          memCacheHeight: memHeight,
          maxWidthDiskCache: diskMaxWidth,
          maxHeightDiskCache: diskMaxHeight,
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          placeholder: (context, url) => placeholder(Icons.image_outlined),
          errorWidget: (context, url, error) =>
              placeholder(Icons.broken_image_outlined),
        );
      },
    );
  }
}