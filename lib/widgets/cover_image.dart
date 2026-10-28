import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => placeholder(Icons.image_outlined),
      errorWidget: (context, url, error) => placeholder(Icons.broken_image_outlined),
    );
  }
}