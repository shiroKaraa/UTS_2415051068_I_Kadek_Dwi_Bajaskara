import 'package:flutter/material.dart';
import '../../core/app_sizes.dart';

class ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller; 

  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller, 
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller, 
      padding: const EdgeInsets.all(AppSizes.spacingM),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.55,
        mainAxisSpacing: AppSizes.spacingM,
        crossAxisSpacing: AppSizes.spacingM,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}