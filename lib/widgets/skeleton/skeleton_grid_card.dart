import 'package:flutter/material.dart';
import 'skeleton_base.dart';

class SkeletonGridCard extends StatelessWidget {
  const SkeletonGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const SkeletonBox(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const SkeletonBox(height: 16, width: double.infinity),
          const SizedBox(height: 4),
          const SkeletonBox(height: 12, width: 80),
        ],
      ),
    );
  }
}