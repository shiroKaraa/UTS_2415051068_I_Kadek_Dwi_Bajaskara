import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';

class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double? height;

  const ShimmerLoading({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.shimmerHighlight),
      ),
    );
  }
}