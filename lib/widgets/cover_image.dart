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
    final canResize = width != null && width!.isFinite;

    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: canResize ? (width! * dpr).round() : null,
      placeholder: (context, url) => placeholder(Icons.image_outlined),
      errorWidget: (context, url, error) =>
          placeholder(Icons.broken_image_outlined),
    );
  }
}