import 'package:flutter/material.dart';

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
    
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: canResize ? (width! * dpr).round() : null,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return placeholder(Icons.image_outlined);
      },
      errorBuilder: (context, error, stackTrace) => placeholder(Icons.broken_image_outlined),
    );
  }
}